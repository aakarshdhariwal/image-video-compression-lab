function decode_intra(coded_file,decoded_yuv_file)
load(coded_file,'width','height','transform_blocksize','qp','huffman_table','bitstream');
[bitstream,signal]=decode_signal_from_huffman_bitstream(bitstream,huffman_table);
run_decode=blockbased_decoding_from_runlevel_representation(signal,transform_blocksize);
zigzag_scanned=optional_dc_prediction_inverse(run_decode);
inv_zigzag=blockbased_decoding_from_zigzag_scanned(zigzag_scanned,transform_blocksize,width,height);
quantisation_matrix=get_quantisation_matrix(qp,transform_blocksize);
out_image=blockbased_dequantizer_from_levels(inv_zigzag,quantisation_matrix);
inv_dct=blockbased_idct_on_image(out_image,transform_blocksize);
index1=find(inv_dct<0);
inv_dct(index1)=0;
index2=find(inv_dct>1);
inv_dct(index2)=1;
retval=yuv_write_one_frame(decoded_yuv_file,1,inv_dct);
end

