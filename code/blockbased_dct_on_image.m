function output_image=blockbased_dct_on_image(input_image,blocksize)
% output_image=blockbased_dct_on_image(input_image,blocksize)
%
% Applies a two-dimensional DCT independently to each blocksize x blocksize
% block of input_image (Exercise 5.1). The transform is computed as
% T*block*T' with the orthonormal DCT-II basis from dct_matrix.m, which is
% identical to MATLAB's dct2 for a square block but needs no toolbox or
% Octave package (Octave's 'image' package declares dct2 but does not
% actually implement it).
[rows,cols]=size(input_image);
transform_matrix=dct_matrix(blocksize);
output_image=zeros(rows,cols);
for i=1:blocksize:rows
    for j=1:blocksize:cols
        block=input_image(i:i+blocksize-1,j:j+blocksize-1);
        output_image(i:i+blocksize-1,j:j+blocksize-1)=transform_matrix*block*transform_matrix';
    end
end
end
