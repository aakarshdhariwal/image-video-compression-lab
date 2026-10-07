function [bd_rate_percent,bd_quality]=bd_rate(reference_rate,reference_quality,test_rate,test_quality)
% [bd_rate_percent,bd_quality]=bd_rate(reference_rate,reference_quality,test_rate,test_quality)
%
% Bjontegaard-Delta rate and quality between two rate-distortion curves --
% the standard way coding efficiency is compared in video coding (G.
% Bjontegaard, "Calculation of average PSNR differences between RD curves",
% ITU-T SG16 VCEG-M33, 2001).
%
% Comparing two codecs by quoting PSNR at one QP is misleading, because the
% two operating points sit at different bitrates. BD-rate instead measures
% the average difference in bitrate between the two curves over the quality
% range they share: a third-order polynomial is fitted to quality against
% log10(rate) for each curve, both are integrated over the overlapping
% quality interval, and the difference of the averages is converted back out
% of the log domain.
%
% Inputs are vectors of equal length; quality may be PSNR in dB or SSIM.
%
% Returns:
%   bd_rate_percent  average bitrate change of the test curve relative to the
%                    reference, in percent. NEGATIVE means the test codec
%                    needs fewer bits for the same quality, i.e. it is better.
%   bd_quality       average quality change at equal bitrate (same units as
%                    the quality inputs). Positive means better.

reference_rate=reference_rate(:);
reference_quality=reference_quality(:);
test_rate=test_rate(:);
test_quality=test_quality(:);

log_reference_rate=log10(reference_rate);
log_test_rate=log10(test_rate);

% ---- BD-rate: fit log(rate) as a function of quality ----
reference_fit=polyfit(reference_quality,log_reference_rate,3);
test_fit=polyfit(test_quality,log_test_rate,3);

quality_low=max(min(reference_quality),min(test_quality));
quality_high=min(max(reference_quality),max(test_quality));
if quality_high<=quality_low
    bd_rate_percent=NaN;
    bd_quality=NaN;
    return;
end

reference_integral=diff(polyval(polyint(reference_fit),[quality_low quality_high]));
test_integral=diff(polyval(polyint(test_fit),[quality_low quality_high]));

average_log_difference=(test_integral-reference_integral)/(quality_high-quality_low);
bd_rate_percent=(10^average_log_difference-1)*100;

% ---- BD-quality: fit quality as a function of log(rate) ----
reference_fit_quality=polyfit(log_reference_rate,reference_quality,3);
test_fit_quality=polyfit(log_test_rate,test_quality,3);

rate_low=max(min(log_reference_rate),min(log_test_rate));
rate_high=min(max(log_reference_rate),max(log_test_rate));
if rate_high<=rate_low
    bd_quality=NaN;
    return;
end

reference_quality_integral=diff(polyval(polyint(reference_fit_quality),[rate_low rate_high]));
test_quality_integral=diff(polyval(polyint(test_fit_quality),[rate_low rate_high]));
bd_quality=(test_quality_integral-reference_quality_integral)/(rate_high-rate_low);
end
