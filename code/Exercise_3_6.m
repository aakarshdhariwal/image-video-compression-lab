%% Reading the input image file
image=imread('flowergarden_cif_frame1.tif');
input_image=double(image)/255; % normalize to [0,1], matching yuv_read_one_frame's convention
%% N is the bit depth from 1-8
N=8;
Rate=[];
Distortion=[];
 for n=1:8
     quantizer_stepsize=1/2^(n-1);
     quant_levels=simple_quantizer(input_image,quantizer_stepsize);
     output_image=simple_dequantizer(quant_levels,quantizer_stepsize);
     Distortion(n)=psnr_of_frame(input_image,output_image);
     Rate(n)=2^n;
     figure();
     imshow(output_image);
 end
 figure();
 plot(Distortion , Rate);
 
