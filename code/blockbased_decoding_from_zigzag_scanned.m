function output_image=blockbased_decoding_from_zigzag_scanned(zigzag_scanned,blocksize,width,height)
% output_image=blockbased_decoding_from_zigzag_scanned(zigzag_scanned,blocksize,width,height)
%
% Inverse of blockbased_encoding_to_zigzag_scanned.m: reconstructs each
% blocksize x blocksize block from its zigzag-scanned row (row by row,
% left to right/top to bottom, matching the encoder's block order) and
% places it back into output_image.
output_image=zeros(height,width);
count=1;
for i=1:blocksize:height
    for j=1:blocksize:width
        out=decoding_from_zigzag_scanned(zigzag_scanned(count,:),blocksize,blocksize);
        output_image(i:i+blocksize-1,j:j+blocksize-1)=out;
        count=count+1;
    end
end
end
