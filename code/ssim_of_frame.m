function output_ssim=ssim_of_frame(original_image,distorted_image)
% output_ssim=ssim_of_frame(original_image,distorted_image)
%
% Mean structural similarity (SSIM) between two frames whose sample values
% lie in [0,1], following Wang et al., "Image Quality Assessment: From Error
% Visibility to Structural Similarity", IEEE TIP 2004: an 11x11 Gaussian
% window of standard deviation 1.5, K1 = 0.01, K2 = 0.03, dynamic range 1.
%
% Added alongside psnr_of_frame.m for the extended benchmarking: PSNR alone
% is a poor predictor of perceived quality at the block-artifact-dominated
% operating points this codec runs at, so every rate-distortion measurement
% in the benchmark suite reports both.
%
% Implemented directly (no toolbox/package dependency) so it behaves
% identically under MATLAB and Octave.

K1=0.01;
K2=0.03;
L=1;                       % dynamic range of the [0,1] normalized frames
C1=(K1*L)^2;
C2=(K2*L)^2;

window=gaussian_window(11,1.5);
window=window/sum(window(:));

mu1=filter2(window,original_image,'valid');
mu2=filter2(window,distorted_image,'valid');

mu1_squared=mu1.*mu1;
mu2_squared=mu2.*mu2;
mu1_mu2=mu1.*mu2;

sigma1_squared=filter2(window,original_image.*original_image,'valid')-mu1_squared;
sigma2_squared=filter2(window,distorted_image.*distorted_image,'valid')-mu2_squared;
sigma12=filter2(window,original_image.*distorted_image,'valid')-mu1_mu2;

ssim_map=((2*mu1_mu2+C1).*(2*sigma12+C2))./((mu1_squared+mu2_squared+C1).*(sigma1_squared+sigma2_squared+C2));
output_ssim=mean(ssim_map(:));
end

function window=gaussian_window(window_size,sigma)
half=(window_size-1)/2;
[x,y]=meshgrid(-half:half,-half:half);
window=exp(-(x.^2+y.^2)/(2*sigma^2));
end
