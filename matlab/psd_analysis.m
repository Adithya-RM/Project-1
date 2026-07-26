function [pxx, f] = psd_analysis(signal_in, fs, window_length, overlap_pct, nfft)
% PSD_ANALYSIS Estimates Power Spectral Density via Welch's Method.
%
%   [PXX, F] = PSD_ANALYSIS(SIGNAL_IN, FS, WINDOW_LENGTH, OVERLAP_PCT, NFFT)
%   computes the Welch power spectral density (PSD) estimate of the VAG signal.
%
%   Default Parameters:
%     fs            = 1000 Hz
%     window_length = 256 points (Hamming window)
%     overlap_pct   = 50% (128 overlap points)
%     nfft          = 512 points
%
%   Inputs:
%     signal_in     - 1D preprocessed VAG signal vector
%     fs            - Sampling frequency in Hz (default: 1000 Hz)
%     window_length - Window length in samples (default: 256)
%     overlap_pct   - Overlap percentage 0-100 (default: 50%)
%     nfft          - Number of FFT points (default: 512)
%
%   Outputs:
%     pxx - Power Spectral Density estimate (V^2/Hz)
%     f   - Frequency vector (Hz)
%
%   Authors: Adarsh V V, Adithya RM, Shivabalan Karthikeyan
%   Course: BBMD202L - Bio Signal Analysis (VIT Vellore)

    if nargin < 2, fs = 1000; end
    if nargin < 3, window_length = 256; end
    if nargin < 4, overlap_pct = 50; end
    if nargin < 5, nfft = 512; end

    win = hamming(window_length);
    noverlap = round(window_length * (overlap_pct / 100));

    [pxx, f] = pwelch(signal_in, win, noverlap, nfft, fs);
end
