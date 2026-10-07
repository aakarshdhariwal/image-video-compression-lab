function output_image=blockbased_dequantizer_from_levels(input_levels,quantizer_matrix)
% output_image=blockbased_dequantizer_from_levels(input_levels,quantizer_matrix)
%
% Inverse of blockbased_quantizer_to_levels.m: tiles quantizer_matrix across
% the whole (level-valued) image and applies scalar_dequantizer.m in one
% shot. See verify_blk_quant.m for the expected input/output values.
[rows,cols]=size(input_levels);
[q_rows,q_cols]=size(quantizer_matrix);
n_rows=ceil(rows/q_rows);
n_cols=ceil(cols/q_cols);
tiled_quantizer_matrix=repmat(quantizer_matrix,n_rows,n_cols);
tiled_quantizer_matrix=tiled_quantizer_matrix(1:rows,1:cols);
output_image=scalar_dequantizer(input_levels,tiled_quantizer_matrix);
end
