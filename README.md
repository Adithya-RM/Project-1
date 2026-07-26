# 🦿 Vibroarthrographic (VAG) Knee Signal Analysis & Biomechanical Diagnosis

> **Non-Invasive Articular Cartilage Assessment via Acoustic Emission Processing & Multi-Stage Spectral Analytics**

---

## 📌 Project Overview

Vibroarthrography (VAG) is an advanced non-invasive biomechanical diagnostic technique that measures surface acoustic emissions and transient micro-vibrations generated during active knee joint flexion and extension. 

### 🎯 Key Objectives
- **⚡ Hardware Engineering**: Passive two-resistor voltage divider & bias circuit paired with a flexible piezoelectric polymer patch sensor ($0.1\text{ Hz} - 1\text{ kHz}$) for high-sensitivity acoustic burst capture without mass loading.
- **📍 Anatomical Placement**: Standardized central patellar placement leveraging the patella as a mechanical fulcrum to maximize Signal-to-Noise Ratio (SNR).
- **🧹 Preprocessing & Denoising**: Multi-stage IIR filtering paired with Discrete Wavelet Transform (DWT `db4`, Level 5) soft thresholding to isolate joint friction transients from EMG crosstalk and motion artifacts.
- **📊 Comparative Diagnostics**: Quantitative evaluation across three distinct physiological cohorts:
  - 🟢 **Normal Subject**: Healthy baseline joint sliding.
  - 🟡 **Healthy Athlete**: Conditioned joint under regular high athletic load.
  - 🔴 **Injured Athlete**: Post-trauma joint (5 months into physiotherapy rehabilitation).

---

## 🔄 System Architecture & Complete Procedure Workflow

The end-to-end signal processing and hardware acquisition workflow proceeds through five sequential modules:

![System Workflow](images/workflow.png)

---

## ⚙️ Phase 1: Hardware Engineering & Signal Acquisition Protocol

### 1. Piezoelectric Patch Sensor Selection
- **Sensor Type**: Flexible Piezoelectric Polymer Patch Sensor.
- **Frequency Response**: Broadband sensitivity from $0.1\text{ Hz}$ to $1\text{ kHz}$.
- **Operating Principle**: Converts mechanical strain and acoustic pressure into proportional electric voltage ($V \propto \Delta x$).

### 2. Anatomical Placement Strategy
- **Position**: Centrally over the **patella** secured via medical-grade adhesive tape.
- **Rationale**: The patella functions as a mechanical fulcrum during knee extension, concentrating acoustic emissions from both patellofemoral and tibiofemoral articular interfaces.

![Sensor Setup](hardware/sensor_setup.jpg)

### 3. Passive Signal Conditioning Circuit
- **100 kΩ Load/Bias Resistor**: Provides high-impedance matching ($Z_{in} > 1\text{ M}\Omega$) and DC bias discharge to prevent sensor charge saturation.
- **1 kΩ Attenuation Resistor**: Scales high transient voltage spikes ($\alpha \approx 0.0099$) to a safe $\pm 1\text{ V}$ ADC dynamic range.

![Circuit Diagram](hardware/circuit_diagram.png)

### 4. Data Acquisition Setup & Protocol
- **Sampling Frequency**: $f_s = 2000\text{ Hz}$ (12-bit ADC / DAQ digital interface).
- **Subject Protocol**: Seated position, paced active knee extension-flexion ($90^\circ \rightarrow 0^\circ \rightarrow 90^\circ$) at 0.5 Hz guided by an audible metronome.

![Oscilloscope Setup](hardware/oscilloscope_setup.jpg)

---

## 🧹 Phase 2: Signal Conditioning Algorithms & Pseudocode

### 1. Raw VAG Signal Characteristics
Raw VAG recordings capture acoustic bursts mixed with baseline motion wander, powerline interference (50 Hz / 100 Hz harmonics), and muscular activity.

![Raw Signals](images/raw_signals.png)

#### 📝 Algorithm 1: Signal Preprocessing & Denoising Pipeline (Pseudocode)
```pseudocode
ALGORITHM: Preprocess_VAG_Signal(raw_signal, fs)
INPUT  : Raw VAG voltage array x(t), Sampling rate fs = 2000 Hz
OUTPUT : Conditioned, denoised, and normalized VAG signal y_norm(t)

BEGIN
    // Step 1: DC Offset Removal
    x_zero_mean = x(t) - MEAN(x(t))
    
    // Step 2: Powerline Notch Filtering (50 Hz & 100 Hz Harmonics)
    [b_notch50, a_notch50]   = DESIGN_IIR_NOTCH(frequency = 50 Hz, Q_factor = 35, fs)
    x_filtered_50            = ZERO_PHASE_FILTER(b_notch50, a_notch50, x_zero_mean)
    
    [b_notch100, a_notch100] = DESIGN_IIR_NOTCH(frequency = 100 Hz, Q_factor = 35, fs)
    x_filtered_notch         = ZERO_PHASE_FILTER(b_notch100, a_notch100, x_filtered_50)
    
    // Step 3: Bandpass Butterworth Filtering (20 Hz - 500 Hz)
    [b_high, a_high] = DESIGN_BUTTERWORTH_HIGHPASS(order = 4, cutoff = 20 Hz, fs)
    x_hp             = ZERO_PHASE_FILTER(b_high, a_high, x_filtered_notch)
    
    [b_low, a_low]   = DESIGN_BUTTERWORTH_LOWPASS(order = 4, cutoff = 500 Hz, fs)
    x_bp             = ZERO_PHASE_FILTER(b_low, a_low, x_hp)
    
    // Step 4: Discrete Wavelet Denoising (Daubechies db4, Level 5)
    [coefficients, tree] = WAVELET_DECOMPOSE(x_bp, wavelet = "db4", level = 5)
    thresholds           = COMPUTE_UNIVERSAL_THRESHOLDS(coefficients, rule = "Soft")
    denoised_coeffs      = APPLY_SOFT_THRESHOLDING(coefficients, thresholds)
    x_denoised           = WAVELET_RECONSTRUCT(denoised_coeffs, tree, wavelet = "db4")
    
    // Step 5: Peak Amplitude Normalization
    y_norm(t) = x_denoised / MAX(ABS(x_denoised))
    
    RETURN y_norm(t)
END
```

![Filtered Signals](images/filtered_signals.png)

---

## 📊 Phase 3: Quantitative Feature Extraction & Pseudocode

### 1. Power Spectral Density (PSD) Analysis via Welch's Method
Quantifies the distribution of signal power across frequency bands ($0 - 500\text{ Hz}$) using Welch's Overlapped Segment Averaging (WOSA).

#### 📝 Algorithm 2: Welch Power Spectral Density Estimation (Pseudocode)
```pseudocode
ALGORITHM: Compute_PSD_Welch(signal, fs, win_size = 256, overlap = 128, nfft = 512)
INPUT  : Preprocessed signal y(t), Sampling rate fs, Hamming window parameters
OUTPUT : Frequency vector f (0-500 Hz), Power density spectrum Pxx (dB/Hz)

BEGIN
    // Step 1: Segment Signal & Apply Hamming Window
    segments = PARTITION_SIGNAL(signal, segment_length = win_size, overlap_length = overlap)
    window   = HAMMING_WINDOW(win_size)
    
    FOR EACH seg IN segments DO
        windowed_seg = seg .* window
        // Step 2: Fast Fourier Transform & Periodogram Computation
        fft_spectrum = FFT(windowed_seg, nfft)
        periodogram  = (1 / (fs * SUM(window^2))) * ABS(fft_spectrum)^2
        ACCUMULATE_PERIODOGRAM(periodogram)
    END FOR
    
    // Step 3: Ensemble Averaging Across Segments
    Pxx_raw = AVERAGE_PERIODOGRAMS()
    f       = COMPUTE_FREQUENCY_AXIS(nfft, fs)  // 0 to fs/2
    
    // Step 4: Conversion to Decibel Scale (dB/Hz)
    Pxx_dB = 10 * LOG10(Pxx_raw)
    
    RETURN f, Pxx_dB
END
```

![PSD Comparison](images/psd.png)

#### 🔍 Key Spectral Findings:
- 🟢 **Normal Subject**: Low overall energy strictly confined below $100\text{ Hz}$ with smooth exponential fall-off.
- 🟡 **Healthy Athlete**: Elevated mid-frequency power ($100 - 250\text{ Hz}$) due to increased muscular tone and tendon stiffness.
- 🔴 **Injured Athlete**: Broad high-frequency spectral spreading ($200 - 450\text{ Hz}$) with multi-peak power bursts caused by articular cartilage surface roughness and friction micro-bursts.

---

### 2. Inter-Signal Cross-Correlation Analysis
Quantifies time-domain structural similarity and phase alignment between subject cohorts.

#### 📝 Algorithm 3: Inter-Signal Cross-Correlation (Pseudocode)
```pseudocode
ALGORITHM: Compute_Cross_Correlation(signal_A, signal_B, fs)
INPUT  : Two preprocessed VAG signals signal_A and signal_B, Sampling rate fs
OUTPUT : Normalized correlation vector R_AB(lag), Peak correlation coefficient r_max

BEGIN
    // Step 1: Compute Unbiased Cross-Correlation
    [raw_corr, raw_lags] = XCORR_COMPUTE(signal_A, signal_B, option = "coeff")
    
    // Step 2: Convert Sample Lags to Time Lags (seconds)
    time_lags = raw_lags / fs
    
    // Step 3: Extract Peak Absolute Correlation Coefficient
    r_max = MAXIMUM(ABS(raw_corr))
    
    RETURN time_lags, raw_corr, r_max
END
```

![Cross Correlation](images/cross_correlation.png)

- **Normal vs. Athlete**: $r \approx 0.88$ (High structural similarity).
- **Normal vs. Injured**: $r \approx 0.52$ (Significant phase disruption due to cartilage friction bursts).

---

### 3. Magnitude-Squared Coherence Analysis
Measures frequency-domain phase coupling and linear correlation ($C_{xy}(f)$) across $0 - 500\text{ Hz}$.

#### 📝 Algorithm 4: Magnitude-Squared Coherence Estimation (Pseudocode)
```pseudocode
ALGORITHM: Compute_MSC_Coherence(signal_X, signal_Y, fs, win_size = 256, overlap = 128, nfft = 512)
INPUT  : Signals signal_X and signal_Y, Sampling rate fs
OUTPUT : Frequency vector f, Coherence spectrum C_xy(f) [0 to 1], Mean coherence value

BEGIN
    // Step 1: Compute Cross-Power & Auto-Power Spectral Densities
    P_xx = WELCH_PSD(signal_X, signal_X, win_size, overlap, nfft, fs)
    P_yy = WELCH_PSD(signal_Y, signal_Y, win_size, overlap, nfft, fs)
    P_xy = WELCH_CROSS_PSD(signal_X, signal_Y, win_size, overlap, nfft, fs)
    
    // Step 2: Compute Magnitude-Squared Coherence
    C_xy(f) = (ABS(P_xy(f))^2) / (P_xx(f) * P_yy(f))
    
    // Step 3: Mean Coherence Index Calculation
    mean_coherence = MEAN(C_xy(f))
    
    RETURN f, C_xy(f), mean_coherence
END
```

![Coherence Analysis](images/coherence.png)

---

## 📈 Summary of Biomechanical Findings

| Feature / Metric | 🟢 Normal Subject | 🟡 Healthy Athlete | 🔴 Injured Athlete (5 mo Rehab) |
| :--- | :--- | :--- | :--- |
| **Peak Voltage Range** | Low ($\pm 0.1\text{ V}$) | Periodic ($\pm 0.2\text{ V}$) | High Transient Acoustic Bursts ($\pm 0.5\text{ V}$) |
| **Dominant Band** | $< 100\text{ Hz}$ | $100 - 250\text{ Hz}$ | Broad Spreading ($200 - 450\text{ Hz}$) |
| **Cross-Corr vs Normal** | $1.00$ (Baseline) | $r = 0.88$ (High Similarity) | $r = 0.52$ (Phase Disruption) |
| **Articular Surface** | Smooth Gliding | High Muscular Tone | Surface Roughness & Friction Bursting |
