function [coded_bits, mse_per_frame]=encoder_opt(input_yuv_file,coded_file,width,height,number_of_frames,transform_blocksize,qp,me_blocksize,me_searchrange,options)
% [coded_bits, mse_per_frame]=encoder_opt(input_yuv_file,coded_file,width,height,
%       number_of_frames,transform_blocksize,qp,me_blocksize,me_searchrange,options)
%
% Optimized hybrid encoder: the same coding structure as encoder_basic.m
% (I-frame, then motion compensated P-frames, block DCT, quantization,
% zigzag, run-level, Huffman) with the codec extensions switchable per run
% so each can be benchmarked against the baseline in isolation.
%
% options (struct, all fields optional, all default false/'full'):
%   .me_strategy  'full' | '3step' | 'log' | 'subpel'   motion estimation
%   .deblock      true to enable the in-loop deblocking filter
%   .rdo          true to enable rate-distortion optimized block decisions
%
% Calls the vectorized Huffman codec (encode_signal_to_huffman_bitstream_fast),
% which verify_fast_huffman_equivalence.m asserts is bit-identical to the
% course reference implementation.

if nargin<10
    options=struct();
end
if ~isfield(options,'me_strategy'); options.me_strategy='full'; end
if ~isfield(options,'deblock');     options.deblock=false;      end
if ~isfield(options,'rdo');         options.rdo=false;          end
if ~isfield(options,'rdo_lambda');  options.rdo_lambda=0.5;     end
if ~isfield(options,'intra_only');  options.intra_only=false;   end

use_subpel=strcmp(options.me_strategy,'subpel');

run_levels=[];
mse_per_frame=[];
motion_vectors=[];
quantisation_matrix=get_quantisation_matrix(qp,transform_blocksize);

for i=1:number_of_frames
    [input, ~, ~]=yuv_read_one_frame(input_yuv_file,i,width,height);

    if i==1 || options.intra_only
        % ---- I-frame: code the frame itself, with no prediction ----
        predicted_frame=zeros(height,width);
    else
        % ---- P-frame: motion estimation against the reconstructed reference ----
        switch options.me_strategy
            case '3step'
                motion_vector=blockbased_motion_search_3stepsearch(input,previous_frame,me_blocksize,me_searchrange);
            case 'log'
                motion_vector=blockbased_motion_search_logsearch(input,previous_frame,me_blocksize,me_searchrange);
            case 'subpel'
                motion_vector=blockbased_motion_search_subpel(input,previous_frame,me_blocksize,me_searchrange);
            otherwise
                motion_vector=blockbased_motion_search(input,previous_frame,me_blocksize,me_searchrange);
        end
        motion_vectors=[motion_vectors; motion_vector];

        % The prediction must be formed from the REFERENCE frame the decoder
        % also has, never from the current input frame.
        if use_subpel
            predicted_frame=blockbased_motion_compensation_subpel(previous_frame,me_blocksize,me_searchrange,motion_vector);
        else
            predicted_frame=blockbased_motion_compensation(previous_frame,me_blocksize,me_searchrange,motion_vector);
        end
    end

    residual=input-predicted_frame;

    coefficients=blockbased_dct_on_image(residual,transform_blocksize);
    out_levels=blockbased_quantizer_to_levels(coefficients,quantisation_matrix);
    if options.rdo
        out_levels=rdo_zero_blocks(out_levels,quantisation_matrix,transform_blocksize,qp,options.rdo_lambda);
    end
    zigzag_scanned=blockbased_encoding_to_zigzag_scanned_fast(out_levels,transform_blocksize);
    runlevels=blockbased_encoding_to_runlevel_representation(zigzag_scanned);
    run_levels=[run_levels; runlevels];

    % ---- decoding loop inside the encoder: reconstruct exactly as the decoder will ----
    run_decode=blockbased_decoding_from_runlevel_representation(runlevels,transform_blocksize);
    inv_zigzag=blockbased_decoding_from_zigzag_scanned_fast(run_decode,transform_blocksize,width,height);
    dequantized=blockbased_dequantizer_from_levels(inv_zigzag,quantisation_matrix);
    reconstructed_residual=blockbased_idct_on_image(dequantized,transform_blocksize);

    reconstructed_image=reconstructed_residual+predicted_frame;
    reconstructed_image(reconstructed_image<0)=0;
    reconstructed_image(reconstructed_image>1)=1;

    if options.deblock
        reconstructed_image=deblock_frame(reconstructed_image,transform_blocksize,qp);
    end

    previous_frame=reconstructed_image;
    mse_per_frame=[mse_per_frame; mse_of_frame(input,reconstructed_image)];
end

% ---- entropy coding, once all frames are processed ----
huffman_table1=create_huffman_table_from_signal(run_levels);
bitstream1=encode_signal_to_huffman_bitstream_fast(bitstream_init(),huffman_table1,run_levels);

if isempty(motion_vectors)
    huffman_table2={};
    bitstream2=bitstream_init();
else
    huffman_table2=create_huffman_table_from_signal(motion_vectors);
    bitstream2=encode_signal_to_huffman_bitstream_fast(bitstream_init(),huffman_table2,motion_vectors);
end

coded_bits=bitstream_get_length(bitstream1)+bitstream_get_length(bitstream2);

me_strategy=options.me_strategy;
deblock_enabled=options.deblock;
intra_only=options.intra_only;
% NOTE: the raw motion_vectors array is deliberately NOT saved. encoder_basic.m
% stored it alongside the Huffman-coded bitstream2, which both double-counts
% the motion data and inflates every rate measured from the coded file size.
% decoder_opt.m recovers the motion vectors by entropy decoding bitstream2.
save(coded_file,'width','height','transform_blocksize','qp','number_of_frames', ...
     'huffman_table1','bitstream1','huffman_table2','bitstream2', ...
     'me_blocksize','me_searchrange','me_strategy','deblock_enabled','intra_only');
end
