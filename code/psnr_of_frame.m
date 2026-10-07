function output_psnr=psnr_of_frame(original_image,distorted_image)
output_mse=mse_of_frame(original_image,distorted_image);
s_hat=1;
psnr=s_hat.^2/output_mse;
output_psnr=10*log10(psnr);
end