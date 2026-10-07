function zigzag_scanned=blockbased_encoding_to_zigzag_scanned_fast(input_image,blocksize)
% zigzag_scanned=blockbased_encoding_to_zigzag_scanned_fast(input_image,blocksize)
%
% Vectorized, result-identical replacement for
% blockbased_encoding_to_zigzag_scanned.m.
%
% The reference version loops over every block and rebuilds the zigzag
% permutation from scratch inside encoding_to_zigzag_scanned for each one
% (1584 blocks per CIF frame, each running a 64-step traversal). Here the
% permutation is built once and every block is scanned in a single indexed
% assignment. Equivalence is asserted by verify_fast_transform_equivalence.m.
[height,width]=size(input_image);
blocks_per_column=height/blocksize;
blocks_per_row=width/blocksize;

permutation_matrix=generate_zigzag_permutation_matrix(blocksize,blocksize);

% Split the image into blocks: dims become
% (row in block, col in block, block column, block row), so that the final
% reshape enumerates blocks left-to-right then top-to-bottom, matching the
% reference implementation's loop order.
blocked=reshape(input_image,[blocksize blocks_per_column blocksize blocks_per_row]);
blocked=permute(blocked,[1 3 4 2]);
blocked=reshape(blocked,[blocksize*blocksize blocks_per_row*blocks_per_column]);

scanned=zeros(size(blocked));
scanned(permutation_matrix(:),:)=blocked;
zigzag_scanned=scanned';
end
