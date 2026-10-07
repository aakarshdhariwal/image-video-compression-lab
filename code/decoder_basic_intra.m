function decoder_basic_intra(coded_file,decoded_yuv_file)
% decoder_basic_intra(coded_file,decoded_yuv_file)
%
% Multi-frame intra-only decoder (Exercise 6.1/6.5): decodes every frame
% saved by encoder_basic_intra.m as an independent I-frame.
%
% NOTE ON FILE NAMING: originally saved as decode_basic_intra.m while the
% function declaration inside already read "decoder_basic_intra" -- a
% mismatch between file name and function name (MATLAB/Octave resolve a
% call by file name, so decoder_basic_intra(...) could never actually be
% invoked as originally saved, only decode_basic_intra(...) could). File
% renamed to match Exercise 6.1's specified name.
%
% Also fixes the original's per-frame slicing bug: it indexed the decoded
% run-level signal with a fixed-width window `signal(i:i+2*n_blocks-1,:)`,
% which does not correspond to any real frame boundary once each block's
% row count varies (as it always does with run-level coding -- see the
% -1,-1 end-of-block marker used by blockbased_encoding_to_runlevel_representation.m).
% This now locates frame boundaries the same way decoder_basic.m does: by
% counting n_blocks worth of -1 end-of-block markers per frame.
load(coded_file,'width','height','transform_blocksize','qp','huffman_table','bitstream','number_of_frames');
retval=[];
n_blocks=height*width/(transform_blocksize^2);
[bitstream,signal]=decode_signal_from_huffman_bitstream(bitstream,huffman_table);
index=find(signal(:,1)==-1);
count=1;
for i=1:number_of_frames
    end_index=index(i*n_blocks);
    run_decode=blockbased_decoding_from_runlevel_representation(signal(count:end_index,:),transform_blocksize);
    inv_zigzag=blockbased_decoding_from_zigzag_scanned(run_decode,transform_blocksize,width,height);
    quantisation_matrix=get_quantisation_matrix(qp,transform_blocksize);
    out_image=blockbased_dequantizer_from_levels(inv_zigzag,quantisation_matrix);
    inv_dct=blockbased_idct_on_image(out_image,transform_blocksize);
    inv_dct(inv_dct<0)=0;
    inv_dct(inv_dct>1)=1;
    retval=[retval;yuv_write_one_frame(decoded_yuv_file,i,inv_dct)];
    count=end_index+1;
end
end
