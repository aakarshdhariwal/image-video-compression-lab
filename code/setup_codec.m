function setup_codec()
% setup_codec()
%
% Prepares the environment for running the codec. Call this once per session
% before encoding, decoding or benchmarking.
%
% Under GNU Octave it loads the 'image' package, which supplies padarray
% (used by the motion estimation and compensation functions) and imshow/
% imwrite (used by the visual results and the JPEG baseline). Under MATLAB
% the equivalent functions come from the Image Processing Toolbox and
% nothing needs loading.
%
% Note that the DCT does NOT depend on any package: it is built from an
% explicit orthonormal basis in dct_matrix.m, precisely because Octave's
% image package declares dct2/idct2 but does not implement them.
if exist('OCTAVE_VERSION','builtin')
    pkg load image;
end
end
