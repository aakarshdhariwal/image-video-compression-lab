function encode_intra(input_yuv_file,coded_file,width,height,transform_blocksize,qp)
[image, ~, ~] =yuv_read_one_frame(input_yuv_file,1,width,height);
output_image=blockbased_dct_on_image(image,transform_blocksize);
quantisation_matrix=get_quantisation_matrix(qp,transform_blocksize);
out_levels=blockbased_quantizer_to_levels(output_image,quantisation_matrix);
zigzag_scanned=blockbased_encoding_to_zigzag_scanned(out_levels,transform_blocksize);
zigzag_scanned=optional_dc_prediction(zigzag_scanned);
runlevels=blockbased_encoding_to_runlevel_representation(zigzag_scanned);
huffman_table=create_huffman_table_from_signal(runlevels);
bitstream=bitstream_init();
bitstream=encode_signal_to_huffman_bitstream(bitstream,huffman_table,runlevels);
%coded_file=bitstream;
save(coded_file,'width','height','transform_blocksize','qp','huffman_table','bitstream');
end

