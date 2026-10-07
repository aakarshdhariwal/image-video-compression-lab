function sequence_ssim=get_ssim_for_sequence(original_yuv_file,reconstructed_yuv_file,width,height,number_of_frames)
% sequence_ssim=get_ssim_for_sequence(original_yuv,reconstructed_yuv,width,height,number_of_frames)
%
% Mean luminance SSIM over a decoded sequence, the structural-similarity
% counterpart of the course-provided get_psnr_for_sequence.m.
per_frame=zeros(1,number_of_frames);
for frame_number=1:number_of_frames
    original=yuv_read_one_frame(original_yuv_file,frame_number,width,height);
    reconstructed=yuv_read_one_frame(reconstructed_yuv_file,frame_number,width,height);
    per_frame(frame_number)=ssim_of_frame(original,reconstructed);
end
sequence_ssim=mean(per_frame);
end
