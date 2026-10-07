function run_verifications(include_slow)
% run_verifications(include_slow)
%
% Runs every verification harness for this codec in one go and reports the
% outcome of each. The verify_*.m harnesses (and their .mat fixtures) are the
% course's own, so this is an independent check of the implementation against
% the reference values the lab shipped, not a self-written test suite.
%
% run_verifications()      runs the fast harnesses (a few seconds)
% run_verifications(true)  additionally runs verify_intra_coding, which
%                          encodes and decodes real CIF frames
%
% Requires the 'image' package under Octave; setup_codec handles that.

if nargin<1; include_slow=false; end

warning('off','all');
set(0,'DefaultFigureVisible','off');
setup_codec();

% Harnesses that take no arguments.
harnesses={ ...
    'verify_scalar_quantizer', ...
    'verify_scalar_dequantizer', ...
    'verify_blk_quant', ...
    'verify_mse_of_frame', ...
    'verify_psnr_of_frame', ...
    'verify_generate_zigzag_permutation_matrix', ...
    'verify_blockbased_dct_on_image', ...
    'verify_blockbased_idct_on_image', ...
    'verify_blockbased_encoding_to_zigzag_scanned', ...
    'verify_blockbased_decoding_from_zigzag_scanned', ...
    'verify_encoding_to_runlevel_representation', ...
    'verify_decoding_from_runlevel_representation', ...
    'verify_blockbased_encoding_to_runlevel_representation', ...
    'verify_blockbased_decoding_from_runlevel_representation', ...
    'verify_fast_huffman_equivalence', ...
    'verify_fast_transform_equivalence' ...
};

for k=1:numel(harnesses)
    printf('\n===== %s =====\n',harnesses{k});
    try
        feval(harnesses{k});
    catch err
        printf('  ERRORED: %s\n',err.message);
    end
    fflush(stdout);
end

% The Huffman harness takes the names of the encoder/decoder to test.
printf('\n===== verify_encode_decode_huffman =====\n');
try
    verify_encode_decode_huffman('encode_signal_to_huffman_bitstream', ...
                                 'decode_signal_from_huffman_bitstream');
catch err
    printf('  ERRORED: %s\n',err.message);
end

if include_slow
    printf('\n===== verify_intra_coding =====\n');
    try
        verify_intra_coding([10 20]);
    catch err
        printf('  ERRORED: %s\n',err.message);
    end
end

printf('\nAll verification harnesses complete.\n');
end
