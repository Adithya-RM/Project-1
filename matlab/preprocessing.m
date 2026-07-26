function [filtered_signal] = preprocessing(raw_signal, fs)
% PREPROCESSING Preprocesses raw Vibroarthrographic (VAG) signals.
%
%   [FILTERED_SIGNAL] = PREPROCESSING(RAW_SIGNAL, FS) applies a sequential
%   multi-stage digital filtering pipeline to isolate the physiological
%   VAG frequency band and eliminate noise sources.
%
%   Pipeline Stages:
%     1. DC Offset Removal: Subtracts signal mean.
%     2. 50 Hz Notch Filter: 4th-order Butterworth bandstop (48-52 Hz).
%     3. 100 Hz Notch Filter: 4th-order Butterworth bandstop (98-102 Hz) for 2nd harmonic.
%     4. 20 Hz High-Pass Filter: 4th-order Butterworth high-pass to remove motion artifacts/EMG.
%     5. 500 Hz Low-Pass Filter: 4th-order Butterworth low-pass to cap VAG bandwidth.
%
%   Inputs:
%     raw_signal - 1D array of voltage measurements from piezoelectric sensor
%     fs         - Sampling frequency in Hz (default: 1000 Hz)
%
%   Outputs:
%     filtered_signal - Filtered time-domain VAG signal
%
%   Note: All filtering uses zero-phase forward-backward filtering (filtfilt)
%   to eliminate phase distortion and preserve temporal alignment of VAG bursts.
%
%   Authors: Adarsh V V, Adithya RM, Shivabalan Karthikeyan
%   Course: BBMD202L - Bio Signal Analysis (VIT Vellore)

    if nargin < 2
        fs = 1000; % Default sampling rate in Hz
    end

    % Stage 1: DC Offset Removal
    sig_dc = raw_signal - mean(raw_signal);

    % Nyquist frequency
    f_nyq = fs / 2;

    % Stage 2: 50 Hz Powerline Notch Filter (48 - 52 Hz)
    Wn_50 = [48, 52] / f_nyq;
    [b_50, a_50] = butter(4, Wn_50, 'stop');
    sig_notch50 = filtfilt(b_50, a_50, sig_dc);

    % Stage 3: 100 Hz Powerline 2nd Harmonic Notch Filter (98 - 102 Hz)
    Wn_100 = [98, 102] / f_nyq;
    [b_100, a_100] = butter(4, Wn_100, 'stop');
    sig_notch100 = filtfilt(b_100, a_100, sig_notch50);

    % Stage 4: 20 Hz High-Pass Filter (removes motion artifacts & low-freq EMG)
    Wn_hp = 20 / f_nyq;
    [b_hp, a_hp] = butter(4, Wn_hp, 'high');
    sig_hp = filtfilt(b_hp, a_hp, sig_notch100);

    % Stage 5: 500 Hz Low-Pass Filter (caps band to VAG range)
    Wn_lp = 500 / f_nyq;
    if Wn_lp >= 1
        Wn_lp = 0.99; % Avoid exceeding Nyquist
    end
    [b_lp, a_lp] = butter(4, Wn_lp, 'low');
    filtered_signal = filtfilt(b_lp, a_lp, sig_hp);
end
