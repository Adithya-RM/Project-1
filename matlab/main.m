% MAIN.M - Comparative Vibroarthrographic (VAG) Knee Signal Analysis Pipeline
%
% Master script to execute full VAG signal acquisition preprocessing,
% wavelet denoising, PSD estimation, cross-correlation, and coherence analysis
% across three subject physiological conditions:
%   1. Normal Individual (Healthy baseline)
%   2. Healthy Athlete (Conditioned joint under load)
%   3. Injured Athlete (5 months into physiotherapy rehabilitation)
%
% Authors: Adarsh V V (23BML0100), Adithya RM (23BML052), Shivabalan Karthikeyan (23BML0065)
% Faculty Advisor: Dr. N. Sharmila
% Institution: VIT Vellore, School of Electronics Engineering (SENSE)
% Course: BBMD202L - Bio Signal Analysis

clc; clear; close all;

%% 1. Load Raw VAG Signal Data
fprintf('=== 1. Loading Raw VAG Signal CSV Files ===\n');

raw_normal_data  = readtable('../data/raw/normal.csv');
raw_athlete_data = readtable('../data/raw/athlete.csv');
raw_injured_data = readtable('../data/raw/injured.csv');

t = raw_normal_data.time;
sig_normal_raw  = raw_normal_data.voltage;
sig_athlete_raw = raw_athlete_data.voltage;
sig_injured_raw = raw_injured_data.voltage;

fs = 1 / (t(2) - t(1)); % Determine sampling rate
fprintf('Sampling Frequency fs = %.1f Hz\n', fs);

%% 2. Signal Preprocessing & Filtering Pipeline
fprintf('\n=== 2. Running Digital Preprocessing Pipeline ===\n');

sig_normal_filt  = preprocessing(sig_normal_raw, fs);
sig_athlete_filt = preprocessing(sig_athlete_raw, fs);
sig_injured_filt = preprocessing(sig_injured_raw, fs);

%% 3. Wavelet Denoising (db4, level 5)
fprintf('\n=== 3. Running Wavelet Denoising (db4, level 5) ===\n');

sig_normal_den  = wavelet_denoising(sig_normal_filt, 'db4', 5);
sig_athlete_den = wavelet_denoising(sig_athlete_filt, 'db4', 5);
sig_injured_den = wavelet_denoising(sig_injured_filt, 'db4', 5);

%% 4. Power Spectral Density (PSD) Analysis via Welch Method
fprintf('\n=== 4. Computing Power Spectral Density (PSD) ===\n');

win_len = 256;
overlap = 50;
nfft    = 512;

[pxx_norm, f_norm] = psd_analysis(sig_normal_den, fs, win_len, overlap, nfft);
[pxx_ath,  f_ath]  = psd_analysis(sig_athlete_den, fs, win_len, overlap, nfft);
[pxx_inj,  f_inj]  = psd_analysis(sig_injured_den, fs, win_len, overlap, nfft);

%% 5. Inter-Signal Cross-Correlation Analysis
fprintf('\n=== 5. Computing Inter-Signal Cross-Correlation ===\n');

[r_NA, lags_NA, max_r_NA] = cross_correlation(sig_normal_den, sig_athlete_den);
[r_NI, lags_NI, max_r_NI] = cross_correlation(sig_normal_den, sig_injured_den);
[r_AI, lags_AI, max_r_AI] = cross_correlation(sig_athlete_den, sig_injured_den);

fprintf('Peak Correlation Coefficients:\n');
fprintf('  Normal vs Athlete:  r = %.4f\n', max_r_NA);
fprintf('  Normal vs Injured:  r = %.4f\n', max_r_NI);
fprintf('  Athlete vs Injured: r = %.4f\n', max_r_AI);

%% 6. Magnitude-Squared Coherence Analysis
fprintf('\n=== 6. Computing Magnitude-Squared Coherence ===\n');

[Cxy_NA, f_coh, mean_c_NA] = coherence_analysis(sig_normal_den, sig_athlete_den, fs, win_len, overlap, nfft);
[Cxy_NI, ~,     mean_c_NI] = coherence_analysis(sig_normal_den, sig_injured_den, fs, win_len, overlap, nfft);
[Cxy_AI, ~,     mean_c_AI] = coherence_analysis(sig_athlete_den, sig_injured_den, fs, win_len, overlap, nfft);

fprintf('Mean Coherence (0-500 Hz):\n');
fprintf('  Normal vs Athlete:  Mean Coherence = %.4f\n', mean_c_NA);
fprintf('  Normal vs Injured:  Mean Coherence = %.4f\n', mean_c_NI);
fprintf('  Athlete vs Injured: Mean Coherence = %.4f\n', mean_c_AI);

%% 7. Generate Visualizations & Figures
fprintf('\n=== 7. Generating Output Figures ===\n');

% Figure 1: Raw Signals
figure('Name', 'Raw VAG Signals');
plot(t, sig_normal_raw, 'b', 'LineWidth', 1); hold on;
plot(t, sig_athlete_raw, 'g', 'LineWidth', 1);
plot(t, sig_injured_raw, 'r', 'LineWidth', 1);
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Raw VAG Signals Across Physiological Conditions');
legend('Normal', 'Athlete', 'Injured Athlete');
grid on;

% Figure 2: Filtered Signals
figure('Name', 'Filtered & Denoised VAG Signals');
plot(t, sig_normal_den, 'b', 'LineWidth', 1); hold on;
plot(t, sig_athlete_den, 'g', 'LineWidth', 1);
plot(t, sig_injured_den, 'r', 'LineWidth', 1);
xlabel('Time (s)'); ylabel('Voltage (V)');
title('Preprocessed & Wavelet Denoised VAG Signals');
legend('Normal', 'Athlete', 'Injured Athlete');
grid on;

% Figure 3: Comparative PSD
figure('Name', 'Power Spectral Density Comparison');
plot(f_norm, 10*log10(pxx_norm), 'b', 'LineWidth', 1.5); hold on;
plot(f_ath,  10*log10(pxx_ath),  'g', 'LineWidth', 1.5);
plot(f_inj,  10*log10(pxx_inj),  'r', 'LineWidth', 1.5);
xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
title('Comparative Power Spectral Density (PSD)');
legend('Normal', 'Athlete', 'Injured Athlete (5 mo rehab)');
xlim([0 500]); grid on;

fprintf('Analysis Pipeline Execution Complete!\n');
