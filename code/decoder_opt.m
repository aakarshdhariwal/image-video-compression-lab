function decoder_opt(coded_file,decoded_yuv_file)
% decoder_opt(coded_file,decoded_yuv_file)
%
% Decoder matching encoder_opt.m. Reads which extensions the encoder used
% (motion estimation strategy, in-loop deblocking) from the coded file so
% that encoder and decoder reconstruct bit-exactly the same frames. The
% rate-distortion optimized block decision needs no decoder support at all:
% it only ever zeroes coefficients, which the existing syntax already
% represents.
load(coded_file,'width','height','transform_blocksize','qp','number_of_frames', ...
     'huffman_table1','bitstream1','huffman_table2','bitstream2', ...
     'me_blocksize','me_searchrange','me_strategy','deblock_enabled','intra_only');

use_subpel=strcmp(me_strategy,'subpel');
quantisation_matrix=get_quantisation_matrix(qp,transform_blocksize);

n_blocks=height*width/(transform_blocksize^2);
mv_blocks_per_frame=(height/me_blocksize)*(width/me_blocksize);

[~,run_levels]=decode_signal_from_huffman_bitstream_fast(bitstream1,huffman_table1);
if isempty(huffman_table2)
    motion_vectors=[];
else
    [~,motion_vectors]=decode_signal_from_huffman_bitstream_fast(bitstream2,huffman_table2);
end

index=find(run_levels(:,1)==-1);
count=1;
mv_count=1;

for i=1:number_of_frames
    end_index=index(i*n_blocks);

    if i==1 || intra_only
        predicted_frame=zeros(height,width);
    else
        mv_end=mv_count+mv_blocks_per_frame-1;
        frame_motion_vectors=motion_vectors(mv_count:mv_end,:);
        if use_subpel
            predicted_frame=blockbased_motion_compensation_subpel(reference_frame,me_blocksize,me_searchrange,frame_motion_vectors);
        else
            predicted_frame=blockbased_motion_compensation(reference_frame,me_blocksize,me_searchrange,frame_motion_vectors);
        end
        mv_count=mv_end+1;
    end

    run_decode=blockbased_decoding_from_runlevel_representation(run_levels(count:end_index,:),transform_blocksize);
    inv_zigzag=blockbased_decoding_from_zigzag_scanned_fast(run_decode,transform_blocksize,width,height);
    dequantized=blockbased_dequantizer_from_levels(inv_zigzag,quantisation_matrix);
    reconstructed_residual=blockbased_idct_on_image(dequantized,transform_blocksize);

    reconstructed_image=reconstructed_residual+predicted_frame;
    reconstructed_image(reconstructed_image<0)=0;
    reconstructed_image(reconstructed_image>1)=1;

    if deblock_enabled
        reconstructed_image=deblock_frame(reconstructed_image,transform_blocksize,qp);
    end

    yuv_write_one_frame(decoded_yuv_file,i,reconstructed_image);
    reference_frame=reconstructed_image;
    count=end_index+1;
end
end
