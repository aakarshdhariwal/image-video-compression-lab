function output_image=blockbased_decoding_from_zigzag_scanned_fast(zigzag_scanned,blocksize,width,height)
% output_image=blockbased_decoding_from_zigzag_scanned_fast(zigzag_scanned,blocksize,width,height)
%
% Vectorized, result-identical replacement for
% blockbased_decoding_from_zigzag_scanned.m -- the exact inverse of
% blockbased_encoding_to_zigzag_scanned_fast.m. Equivalence against the
% reference implementation is asserted by verify_fast_transform_equivalence.m.
blocks_per_column=height/blocksize;
blocks_per_row=width/blocksize;

permutation_matrix=generate_zigzag_permutation_matrix(blocksize,blocksize);

scanned=zigzag_scanned';
blocked=scanned(permutation_matrix(:),:);

blocked=reshape(blocked,[blocksize blocksize blocks_per_row blocks_per_column]);
blocked=permute(blocked,[1 4 2 3]);
output_image=reshape(blocked,[height width]);
end
