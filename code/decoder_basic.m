function decoder_basic(coded_file,decoded_yuv_file)
% decoder_basic(coded_file,decoded_yuv_file)
%
% Basic hybrid decoder (Exercise 6.7/6.9): decodes frame 1 as an I-frame
% and all subsequent frames as motion-compensated P-frames, matching
% encoder_basic.m.
%
% NOTE ON FILE NAMING: originally saved as decode_basic.m with an internal
% function name of the same name; renamed (file + declaration) to
% decoder_basic to match the name the lab manual (Exercise 6.7) and
% get_dr_result.m's own documentation/example call actually expect ---
% MATLAB/Octave resolve a call by file name, so decode_basic(...) could
% never be invoked as decoder_basic(...) as originally saved.
load(coded_file,'width','height','transform_blocksize','qp','huffman_table1','bitstream1','huffman_table2','bitstream2','me_blocksize','me_searchrange');
retval=[];
n_blocks=height*width/(transform_blocksize^2);
mv_blocks_per_frame=(height/me_blocksize)*(width/me_blocksize);
[bitstream,run_levels]=decode_signal_from_huffman_bitstream(bitstream1,huffman_table1);
[bitstream2,motion_vectors]=decode_signal_from_huffman_bitstream(bitstream2,huffman_table2);
index=find(run_levels(:,1)==-1);
number_of_frames=length(index)/n_blocks;
count=1;
mv_count=1;
for i=1:number_of_frames
    end_index = index(i*n_blocks);
    if i==1
        run_decode=blockbased_decoding_from_runlevel_representation(run_levels(count:end_index,:),transform_blocksize);
        inv_zigzag=blockbased_decoding_from_zigzag_scanned(run_decode,transform_blocksize,width,height);
        quantisation_matrix=get_quantisation_matrix(qp,transform_blocksize);
        out_image=blockbased_dequantizer_from_levels(inv_zigzag,quantisation_matrix);
        inv_dct=blockbased_idct_on_image(out_image,transform_blocksize);
        inv_dct(inv_dct<0)=0;
        inv_dct(inv_dct>1)=1;
        reconstructed_image=inv_dct;
    else
        mv_end=mv_count+mv_blocks_per_frame-1;
        predicted_frame=blockbased_motion_compensation(reference_frame,me_blocksize,me_searchrange,motion_vectors(mv_count:mv_end,:));
        run_decode=blockbased_decoding_from_runlevel_representation(run_levels(count:end_index,:),transform_blocksize);
        inv_zigzag=blockbased_decoding_from_zigzag_scanned(run_decode,transform_blocksize,width,height);
        quantisation_matrix=get_quantisation_matrix(qp,transform_blocksize);
        out_image=blockbased_dequantizer_from_levels(inv_zigzag,quantisation_matrix);
        inv_dct=blockbased_idct_on_image(out_image,transform_blocksize);
        reconstructed_image=inv_dct+predicted_frame;
        reconstructed_image(reconstructed_image<0)=0;
        reconstructed_image(reconstructed_image>1)=1;
        mv_count=mv_end+1;
    end
    retval=[retval;yuv_write_one_frame(decoded_yuv_file,i,reconstructed_image)];
    reference_frame=reconstructed_image;
    count=end_index+1;
end
end
