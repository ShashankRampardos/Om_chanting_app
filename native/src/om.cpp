// om.cpp
#include "om.h"     
#include<iostream>          
#include <vector>
#include <complex>
#include <cmath>
#include <algorithm>
#include <stdexcept>
#include <deque>
#include <set>
#include <chrono>


constexpr int    SAMPLE_RATE         = 44100;  //below frequency thrasholds are set after taking samples of 3 people.
constexpr double OM_MIN_FREQ         = 140.0;  // allow down to 140 Hz
constexpr double OM_MAX_FREQ         = 820.0;  // allow up to 820 Hz

static double gMagnitudeThreshold = 90.0;

// Recursive Cooley–Tukey FFT
void fft(std::vector<std::complex<double>>& data) {
    size_t n = data.size();
    if (n <= 1) return;
    std::vector<std::complex<double>> even(n/2), odd(n/2);
    for (size_t i = 0; i < n/2; ++i) {
        even[i] = data[i*2];
        odd[i]  = data[i*2 + 1];
    }
    fft(even);
    fft(odd);
    for (size_t k = 0; k < n/2; ++k) {
        auto tw = std::polar(1.0, -2 * M_PI * k / n) * odd[k];
        data[k]       = even[k] + tw;
        data[k + n/2] = even[k] - tw;
    }
}

// Templated MedianQueue for O(log n) insert/pop and O(1) median
template<typename T>
class MedianQueue {
private:
    std::multiset<T> s;
    typename std::multiset<T>::iterator median;
    std::deque<T> q;

public:
    void insert(const T& x) {
        s.insert(x);
        q.push_back(x);
        if (s.size() == 1) {
            median = s.begin();
        } else if (x < *median) {
            if (s.size() % 2 == 0) --median;
        } else {
            if (s.size() % 2 != 0) ++median;
        }
    }

    void pop() {
        if (q.empty()) throw std::runtime_error("MedianQueue::pop(): empty");
        int n = s.size();
        T oldest = q.front();
        q.pop_front();

        auto it = s.find(oldest);
        if (it == median) {
            auto nextMed = s.erase(it);
            if (s.empty()) return;
            if (n % 2 == 1) {                // odd→even
                median = (nextMed == s.begin()
                          ? nextMed
                          : std::prev(nextMed));
            } else {                         // even→odd
                median = nextMed;
            }
        }
        else if (oldest < *median) {
            s.erase(it);
            if (n % 2 == 0) ++median;      // even→odd
        }
        else {
            s.erase(it);
            if (n % 2 == 1) --median;      // odd→even
        }
    }

    T getMedian() const {
        if (s.empty()) throw std::runtime_error("MedianQueue::getMedian(): empty");
        return *median;
    }
    T getMin() const {
        if (s.empty()) throw std::runtime_error("MedianQueue::getMedian(): empty");
        return *s.begin();
    }
    T getMax() const {
        if (s.empty()) throw std::runtime_error("MedianQueue::getMedian(): empty");
        return *prev(s.end());
    } 
    bool empty() const   { return s.empty(); }
    size_t size() const  { return s.size();  }
};

static MedianQueue<double> freqQ, magQ;
static std::deque<std::chrono::steady_clock::time_point> times;
constexpr int WINDOW_MS = 1000;//1000 milli second window for median queue.

// Exposed C API for Flutter FFI
extern "C"
bool detect_om(float* samples,
               int   length,
               double* outFreq,
               double* outMag)
{
    // 1) Zero-pad to next power of two
    size_t n = 1;
    while (n < (size_t)length) n <<= 1;
    std::vector<std::complex<double>> buf(n, 0.0);

    // 2) Copy samples + Hann window
    for (int i = 0; i < length; ++i) {
        double w = 0.5 * (1 - cos(2 * M_PI * i / (length - 1)));
        buf[i] = samples[i] * w;
    }

    // 3) FFT
    fft(buf);

    // 4) Compute magnitudes & find raw peak index
    std::vector<double> M(n/2);
    for (size_t i = 0; i < n/2; ++i) M[i] = std::abs(buf[i]);
    auto   maxIt = std::max_element(M.begin(), M.end());
    size_t k     = std::distance(M.begin(), maxIt);

    // 5) Parabolic interpolation for sub-bin accuracy
    double rawFreq;
    if (k > 0 && k < n/2 - 1) {
        double a = 20*log10(M[k-1]);
        double b = 20*log10(M[k]);
        double c = 20*log10(M[k+1]);
        double shift = 0.5 * (a - c) / (a - 2*b + c);
        rawFreq = (k + shift) * SAMPLE_RATE / n;
    } else {
        rawFreq = (double)k * SAMPLE_RATE / n;
    }
    double rawMag = *maxIt;

    // 6) Insert into median queues with timestamp
    auto now = std::chrono::steady_clock::now();
    times.push_back(now);
    freqQ.insert(rawFreq);
    magQ.insert(rawMag);

    // 7) Evict samples older than WINDOW_MS
    while (!times.empty() &&
           std::chrono::duration_cast<std::chrono::milliseconds>(now - times.front()).count()
             > WINDOW_MS)
    {   
        times.pop_front();
        freqQ.pop();
        magQ.pop();
    }

    // 8) Read smoothed (median) values
    double medFreq = freqQ.getMedian();
    double medMag  = magQ.getMedian();

    *outFreq = medFreq;
    *outMag  = medMag;
    std :: cout<<gMagnitudeThreshold<<std :: endl;
    // 9) Range + threshold check
    return (medFreq >= OM_MIN_FREQ &&
            medFreq <= OM_MAX_FREQ &&
            medMag  >  gMagnitudeThreshold);
}

extern "C" void calibrate() {
    if (magQ.size() < 2) return;  // ensure at least two samples

    // compute your “raw” threshold, 95th percentile using uniform distribution percentile formula and multiply with 1.5 to get slightly higher value
    double rawThresh = (magQ.getMin()
                       + 0.95 * (magQ.getMax() - magQ.getMin()))
                       * 1.5;

    // exponential smoothing: β fraction of new, (1-β) of old
    const double β = 0.2;  
    gMagnitudeThreshold = β * rawThresh
                        + (1.0 - β) * gMagnitudeThreshold;
}

extern "C" void resetOmState() {
    // Clear median queues
    while (!freqQ.empty()) freqQ.pop();
    while (!magQ.empty())  magQ.pop();
    // Clear timestamps
    times.clear();
    
}

// For manual override from Dart
extern "C" void setMagnitudeThreshold(double t) {
    gMagnitudeThreshold = t;
}

extern "C" double getMagnitudeThreshold() {
    return gMagnitudeThreshold;
}


//calibration part code below...

// static std::vector<double> calibPeaks;

// Call at start of calibration
// extern "C" void startCalibration() {
//     calibPeaks.clear();
// }

// // Call once per audio frame of size `length`
// extern "C" void addCalibrationFrame(float* samples, int length) {
//     //Copy+window+zero-pad
//     size_t n = 1; while (n < (size_t)length) n <<= 1;
//     std::vector<std::complex<double>> buf(n, 0.0);
//     for (int i = 0; i < length; ++i) {
//         double w = 0.5 * (1 - cos(2*M_PI*i/(length-1)));
//         buf[i] = samples[i] * w;
//     }
    
//     fft(buf);
   
//     double maxMag = 0.0;
//     for (size_t i = 0; i < n/2; ++i)
//         maxMag = std::max(maxMag, std::abs(buf[i]));
//     calibPeaks.push_back(maxMag);
// }

// // Call after all frames are added—returns new threshold
// extern "C" double finishCalibration() {
//     if (calibPeaks.empty()) return gMagnitudeThreshold;
//     size_t idx = size_t(calibPeaks.size() * 0.95);
//     std::nth_element(calibPeaks.begin(),
//                      calibPeaks.begin() + idx,
//                      calibPeaks.end());
//     double p95 = calibPeaks[idx];
//     gMagnitudeThreshold = 100;
//     return gMagnitudeThreshold;
// }
