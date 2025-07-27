#ifndef OM_H
#define OM_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

/// Core OM detection
bool detect_om(float* samples, int length);

// /// Calibration workflow
// void startCalibration();
// void addCalibrationFrame(float* samples, int length);
// void finishCalibration();

// /// Threshold controls
// void setMagnitudeThreshold(double threshold);
// double getMagnitudeThreshold();

#ifdef __cplusplus
}
#endif

#endif // OM_H
