function output_levels=blockbased_quantizer_to_levels(input_image,quantizer_matrix)
% output_levels=blockbased_quantizer_to_levels(input_image,quantizer_matrix)
%
% Applies scalar_quantizer block-wise across the whole image: the
% quantizer_matrix (one transform block, e.g. 8x8) is tiled to cover
% input_image and then the same element-wise scalar quantizer used
% elsewhere in this codec (scalar_quantizer.m) is applied in one shot.
% See verify_blk_quant.m for the expected input/output values.
[rows,cols]=size(input_image);
[q_rows,q_cols]=size(quantizer_matrix);
n_rows=ceil(rows/q_rows);
n_cols=ceil(cols/q_cols);
tiled_quantizer_matrix=repmat(quantizer_matrix,n_rows,n_cols);
tiled_quantizer_matrix=tiled_quantizer_matrix(1:rows,1:cols);
output_levels=scalar_quantizer(input_image,tiled_quantizer_matrix);
end
