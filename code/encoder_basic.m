function [coded_bits, mse_per_frame]=encoder_basic(input_yuv_file,coded_file,width,height,number_of_frames,transform_blocksize,qp,me_blocksize,me_searchrange)
% [coded_bits, mse_per_frame]=encoder_basic(input_yuv_file,coded_file,width,height,
%       number_of_frames,transform_blocksize,qp,me_blocksize,me_searchrange)
%
% Basic hybrid encoder (Exercise 6.7/6.8): frame 1 as an I-frame, all
% following frames as motion compensated P-frames.
run_levels=[];
coded_bits=0;
mse_per_frame=[];
motion_vectors=[];
for i=1:number_of_frames
[input, ~, ~] =yuv_read_one_frame(input_yuv_file,i,width,height);
% predicted frame
if i==1
    predicted_frame=zeros(height,width);
    image=input-predicted_frame;
else
    motion_vector=blockbased_motion_search(input,previous_frame,me_blocksize,me_searchrange);
    motion_vectors=[motion_vectors; motion_vector];
    % FIX: the prediction has to be built from the reconstructed REFERENCE
    % frame (previous_frame), which is what the decoder has. The original
    % passed the current frame `input` here, so the encoder predicted a
    % frame from itself while the decoder predicted from the reference --
    % encoder and decoder drifted apart completely.
    predicted_frame=blockbased_motion_compensation(previous_frame,me_blocksize,me_searchrange,motion_vector);
    image=input-predicted_frame;
end

output_image=blockbased_dct_on_image(image,transform_blocksize);
quantisation_matrix=get_quantisation_matrix(qp,transform_blocksize);
out_levels=blockbased_quantizer_to_levels(output_image,quantisation_matrix);
zigzag_scanned=blockbased_encoding_to_zigzag_scanned(out_levels,transform_blocksize);
runlevels=blockbased_encoding_to_runlevel_representation(zigzag_scanned);
run_levels=[run_levels; runlevels];

% step 2 including decoder in encoder

run_decode=blockbased_decoding_from_runlevel_representation(runlevels,transform_blocksize);
inv_zigzag=blockbased_decoding_from_zigzag_scanned(run_decode,transform_blocksize,width,height);
out_image=blockbased_dequantizer_from_levels(inv_zigzag,quantisation_matrix);
inv_dct=blockbased_idct_on_image(out_image,transform_blocksize);
% FIX: what the IDCT returns is the decoded RESIDUAL; the reconstructed
% frame is that residual plus the prediction. The original stored the bare
% residual as the reference for the next frame (and clipped it to [0,1],
% which is also wrong for a difference signal -- cf. Exercise 6.8, note 4).
reconstructed_image=inv_dct+predicted_frame;
reconstructed_image(reconstructed_image<0)=0;
reconstructed_image(reconstructed_image>1)=1;
previous_frame=reconstructed_image;
% FIX: the MSE of the frame is measured between the ORIGINAL input frame and
% its reconstruction, not between the residual and the reconstruction.
mse=mse_of_frame(input,reconstructed_image);
mse_per_frame=[mse_per_frame; mse];

end

huffman_table1=create_huffman_table_from_signal(run_levels);
huffman_table2=create_huffman_table_from_signal(motion_vectors);

bitstream=bitstream_init();
bitstream1=encode_signal_to_huffman_bitstream(bitstream,huffman_table1,run_levels);
bitstream2=encode_signal_to_huffman_bitstream(bitstream,huffman_table2,motion_vectors);
coded_bits=bitstream_get_length(bitstream1)+bitstream_get_length(bitstream2);
number_of_frames_coded=number_of_frames;
save(coded_file,'width','height','transform_blocksize','qp','huffman_table1','bitstream1','huffman_table2','bitstream2','me_blocksize','me_searchrange','number_of_frames_coded');
end

