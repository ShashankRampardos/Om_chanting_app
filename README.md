# Live Om Counting & Meditation App (Flutter)

A real-time audio signal processing mobile application that detects and counts live **Om chants** using microphone input, FFT-based frequency analysis, and adaptive background noise calibration.

---

## Demo (Real-Time Detection)


https://github.com/user-attachments/assets/a91ad91a-ae67-4450-8239-55fb3a46f089


> Live microphone input → frequency analysis → real-time Om detection  
> (Replace `VIDEO_ID_HERE` with the GitHub video asset link)

---

## Overview

This project focuses on building a low-latency, real-time system by combining **Flutter UI**, **native C++ DSP**, and efficient cross-layer communication.  
The goal is to perform accurate Om chant detection without using machine learning, relying purely on signal processing techniques.

---

## Core Functionality

- Continuous microphone audio capture
- FFT-based spectral analysis for chant detection
- Adaptive background noise calibration
- Sub-second detection latency
- Real-time data transfer between native and Flutter layers

---

## System Architecture

### Audio Processing
- Continuous PCM audio sampling from microphone
- Fast Fourier Transform (FFT) for frequency-domain analysis
- Frequency band and amplitude analysis tuned for Om chanting
- Noise-floor calibration to minimize false positives

### Native Performance Layer
- Performance-critical DSP implemented in native C++ (Android NDK)
- Optimized buffers and FFT window sizes
- Flutter ↔ C++ integration via platform channels

### Frontend
- Flutter-based UI
- Riverpod for predictable and scalable state management
- Modular architecture for future analytics

### Backend (In Progress)
- Authentication and analytics service using Go (Golang)
- REST APIs validated using Postman
- External audio assets fetched via Freesound API

---

## Tech Stack

- Flutter (Dart)
- C++ (Android NDK)
- Digital Signal Processing (FFT)
- Riverpod
- Go (Golang)
- REST APIs, Postman
- Freesound API

---

## Project Status

- Core real-time Om detection: Completed
- Native C++ DSP integration: Completed
- Flutter UI: Completed
- Backend authentication & analytics: In progress

---

## Repository

https://github.com/ShashankRampardos/Om_chanting_app
