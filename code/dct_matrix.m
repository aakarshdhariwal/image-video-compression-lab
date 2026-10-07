function transform_matrix=dct_matrix(blocksize)
% transform_matrix=dct_matrix(blocksize)
%
% Returns the orthonormal blocksize x blocksize DCT-II basis matrix T, so
% that the two-dimensional DCT of a block is T*block*T' and the inverse is
% T'*coefficients*T (Exercise 5.1, Eq. 5.1/5.2 of the lab manual).
%
% Implementing the basis explicitly rather than calling dct2/idct2 keeps the
% codec dependency-free: it runs identically under MATLAB and under GNU
% Octave, whose 'image' package declares dct2/idct2 but does not actually
% implement them.
n=0:blocksize-1;
k=(0:blocksize-1)';
transform_matrix=sqrt(2/blocksize)*cos(pi*(2*n+1).*k/(2*blocksize));
transform_matrix(1,:)=transform_matrix(1,:)/sqrt(2);
end
