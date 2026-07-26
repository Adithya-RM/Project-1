function [r, lags, max_r] = cross_correlation(sig1, sig2, maxlag)
% CROSS_CORRELATION Computes normalized cross-correlation between two VAG signals.
%
%   [R, LAGS, MAX_R] = CROSS_CORRELATION(SIG1, SIG2, MAXLAG) calculates the
%   normalized cross-correlation function r(tau) between two signals using xcorr.
%
%   Inputs:
%     sig1   - First 1D signal vector (e.g., Normal VAG)
%     sig2   - Second 1D signal vector (e.g., Athlete VAG)
%     maxlag - Maximum lag displacement in samples (optional)
%
%   Outputs:
%     r     - Normalized cross-correlation sequence (-1 to 1)
%     lags  - Vector of sample lags
%     max_r - Peak absolute cross-correlation coefficient
%
%   Authors: Adarsh V V, Adithya RM, Shivabalan Karthikeyan
%   Course: BBMD202L - Bio Signal Analysis (VIT Vellore)

    if nargin < 3
        [r, lags] = xcorr(sig1, sig2, 'coeff');
    else
        [r, lags] = xcorr(sig1, sig2, maxlag, 'coeff');
    end

    max_r = max(abs(r));
end
