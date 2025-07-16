#ifndef OM_H
#define OM_H

#ifdef __cplusplus
extern "C" {
#endif

bool detect_om(float* samples, int length, double* peakFreq, double* peakMag);

#ifdef __cplusplus
}
#endif

#endif
