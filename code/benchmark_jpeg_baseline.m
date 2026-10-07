function result=benchmark_jpeg_baseline(sequence,quality_values,number_of_frames)
% result=benchmark_jpeg_baseline(sequence,quality_values,number_of_frames)
%
% External reference point for the rate-distortion benchmark: encodes every
% frame of the sequence independently as a JPEG at each quality setting,
% using the imwrite JPEG encoder, and measures the same rate/PSNR/SSIM
% quantities the codec harness measures.
%
% This is an intra-only, still-image baseline, so it is the fair comparison
% for this codec's own intra mode, and the reference that the motion
% compensated (hybrid) mode should beat -- exploiting temporal redundancy is
% precisely what it adds over coding each frame as a picture.

if nargin<3 || isempty(number_of_frames); number_of_frames=5; end

width=352;
height=288;
frame_rate=12.5;

result=struct();
result.quality=quality_values;
result.sequence=sequence;
result.bits=zeros(1,numel(quality_values));
result.rate_kbps=zeros(1,numel(quality_values));
result.psnr=zeros(1,numel(quality_values));
result.ssim=zeros(1,numel(quality_values));

jpeg_file=[tempname() '.jpg'];

for k=1:numel(quality_values)
    quality=quality_values(k);
    total_bits=0;
    psnr_accumulator=zeros(1,number_of_frames);
    ssim_accumulator=zeros(1,number_of_frames);

    for frame_number=1:number_of_frames
        original=yuv_read_one_frame(sequence,frame_number,width,height);
        imwrite(uint8(round(original*255)),jpeg_file,'jpg','Quality',quality);

        file_info=dir(jpeg_file);
        total_bits=total_bits+file_info.bytes*8;

        reconstructed=double(imread(jpeg_file))/255;
        psnr_accumulator(frame_number)=psnr_of_frame(original,reconstructed);
        ssim_accumulator(frame_number)=ssim_of_frame(original,reconstructed);
    end

    result.bits(k)=total_bits;
    result.rate_kbps(k)=total_bits*frame_rate/number_of_frames/1024;
    result.psnr(k)=mean(psnr_accumulator);
    result.ssim(k)=mean(ssim_accumulator);

    printf('  JPEG Q%3d | %8.1f kbit/s | PSNR %6.2f dB | SSIM %6.4f\n', ...
           quality,result.rate_kbps(k),result.psnr(k),result.ssim(k));
    fflush(stdout);
end

if exist(jpeg_file,'file'); delete(jpeg_file); end
end
