function [Cxy, f, mean_coherence] = coherence_analysis(sig1, sig2, fs, window_length, overlap_pct, nfft)
% COHERENCE_ANALYSIS Computes Magnitude-Squared Coherence between VAG signals.
%
%   [CXY, F, MEAN_COHERENCE] = COHERENCE_ANALYSIS(SIG1, SIG2, FS, WINDOW_LENGTH, OVERLAP_PCT, NFFT)
%   computes the magnitude-squared coherence Cxy(f) between two signals using mscohere.
%
%   Coherence Formula:
%     Cxy(f) = |Pxy(f)|^2 / (Pxx(f) * Pyy(f))
%
%   Inputs:
%     sig1          - First signal vector
%     sig2          - Second signal vector
%     fs            - Sampling frequency (Hz) (default: 1000)
%     window_length - Window length in samples (default: 256)
%     overlap_pct   - Overlap percentage (default: 50%)
%     nfft          - Number of FFT points (default: 512)
%
%   Outputs:
%     Cxy            - Magnitude-squared coherence vector (0 to 1)
%     f              - Frequency vector (Hz)
%     mean_coherence - Mean coherence across 0-500 Hz frequency band
%
%   Authors: Adarsh V V, Adithya RM, Shivabalan Karthikeyan
%   Course: BBMD202L - Bio Signal Analysis (VIT Vellore)

    if nargin < 3, fs = 1000; end
    if nargin < 4, window_length = 256; end
    if nargin < 5, overlap_pct = 50; end
    if nargin < 6, nfft = 512; end

    win = hamming(window_length);
    noverlap = round(window_length * (overlap_pct / 100));

    [Cxy, f] = mscohere(sig1, sig2, win, noverlap, nfft, fs);

    % Restrict mean calculation to 0 - 500 Hz VAG band
    idx = (f >= 0) & (f <= 500);
    mean_coherence = mean(Cxy(idx));
end
