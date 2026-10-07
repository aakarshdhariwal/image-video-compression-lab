function [coded_bits, mse_per_frame]=encoder_basic_intra(input_yuv_file,coded_file,width,height,number_of_frames,transform_blocksize,qp)
% for 2 video frames
run_levels=[];
coded_bits=0;
mse_per_frame=[];
motion_vectors=[];
for i=1:number_of_frames
    [image, ~, ~] =yuv_read_one_frame(input_yuv_file,i,width,height);

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
    inv_dct(inv_dct<0)=0;
    inv_dct(inv_dct>1)=1;
    previous_frame=inv_dct;
    mse=mse_of_frame(image,previous_frame);
    mse_per_frame=[mse_per_frame; mse];

end

huffman_table=create_huffman_table_from_signal(run_levels);
bitstream=bitstream_init();
bitstream=encode_signal_to_huffman_bitstream(bitstream,huffman_table,run_levels);

coded_bits=bitstream_get_length(bitstream);
%coded_file=bitstream;
save(coded_file,'width','height','transform_blocksize','qp','huffman_table','bitstream','number_of_frames','motion_vectors');
end

