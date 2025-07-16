// om.cpp
#include "om.h" // make sure to include your header
#include <vector>
#include <cmath>
#include <complex>
#include <algorithm>

const int SAMPLE_RATE = 44100;
const double OM_MIN_FREQ = 150.0;
const double OM_MAX_FREQ = 380.0;
const double MAGNITUDE_THRESHOLD = 400.0;

// FFT and internal detection logic
void fft(std::vector<std::complex<double>>& data) {
    size_t n = data.size();
    if (n <= 1) return;
    std::vector<std::complex<double>> even(n / 2), odd(n / 2);
    for (size_t i = 0; i < n / 2; ++i) {
        even[i] = data[i*2];
        odd[i] = data[i*2 + 1];
    }
    fft(even);
    fft(odd);
    for (size_t k = 0; k < n / 2; ++k) {
        std::complex<double> t = std::polar(1.0, -2 * M_PI * k / n) * odd[k];
        data[k] = even[k] + t;
        data[k + n/2] = even[k] - t;
    }
}

extern "C" bool detect_om(float* samples, int length, double* peakFreq, double* peakMag) {
    std::vector<std::complex<double>> complexSamples;
    for (int i = 0; i < length; ++i)
        complexSamples.push_back(samples[i]);
    
    fft(complexSamples);

    std::vector<double> magnitudes(length / 2);
    for (size_t i = 0; i < magnitudes.size(); ++i)
        magnitudes[i] = std::abs(complexSamples[i]);

    auto maxIt = std::max_element(magnitudes.begin(), magnitudes.end());
    size_t maxIndex = std::distance(magnitudes.begin(), maxIt);

    *peakMag = *maxIt;
    *peakFreq = (double)maxIndex * SAMPLE_RATE / length;

    return (*peakFreq >= OM_MIN_FREQ && *peakFreq <= OM_MAX_FREQ && *peakMag > MAGNITUDE_THRESHOLD);
}
