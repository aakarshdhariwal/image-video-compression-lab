function final_encoder(input_sequence_yuv,coded_file,width,height,nr_of_frames,qp)
% final_encoder(input_sequence_yuv,coded_file,width,height,nr_of_frames,qp)
%
% Uniform-interface wrapper required by Exercise 6.15. Internally calls
% encoder_basic with a fixed, reasonable set of coding parameters (matching
% the ones used for the D(R) comparisons in Exercises 6.11-6.14: transform
% block size 8, motion estimation block size 16, search range 8), so that
% only (sequence, qp) need to be chosen by the caller.
transform_blocksize=8;
me_blocksize=16;
me_searchrange=8;
encoder_basic(input_sequence_yuv,coded_file,width,height,nr_of_frames,transform_blocksize,qp,me_blocksize,me_searchrange);
end
