function [denoised_signal] = wavelet_denoising(signal_in, wname, level)
% WAVELET_DENOISING Performs wavelet-based denoising on VAG signals.
%
%   [DENOISED_SIGNAL] = WAVELET_DENOISING(SIGNAL_IN, WNAME, LEVEL) uses 
%   discrete wavelet transform (DWT) decomposition to suppress residual background
%   noise while preserving non-stationary transient VAG burst events.
%
%   Default Parameters:
%     wname = 'db4'     - Daubechies 4 wavelet basis function
%     level = 5         - 5-level multiresolution decomposition
%     tptr  = 'minimaxi'- Minimax thresholding criterion
%     sorh  = 's'        - Soft thresholding rule
%
%   Inputs:
%     signal_in - 1D filtered VAG signal vector
%     wname     - Wavelet family name (default: 'db4')
%     level     - Decomposition level (default: 5)
%
%   Outputs:
%     denoised_signal - Wavelet-denoised signal
%
%   Authors: Adarsh V V, Adithya RM, Shivabalan Karthikeyan
%   Course: BBMD202L - Bio Signal Analysis (VIT Vellore)

    if nargin < 2, wname = 'db4'; end
    if nargin < 3, level = 5; end

    % Perform wavelet denoising using MATLAB wden function
    % 'minimaxi' = minimax threshold selection
    % 's'        = soft thresholding rule
    % 'sln'      = unscaled noise level estimation
    denoised_signal = wden(signal_in, 'minimaxi', 's', 'sln', level, wname);
end
