function zigzag_scanned=blockbased_encoding_to_zigzag_scanned(input_image,blocksize)
% zigzag_scanned=blockbased_encoding_to_zigzag_scanned(input_image,blocksize)
%
% Splits input_image into blocksize x blocksize blocks (row by row, left to
% right/top to bottom) and zigzag-scans each one via encoding_to_zigzag_scanned,
% stacking the results as rows of zigzag_scanned.
[height,width]=size(input_image);
zigzag_scanned=[];
for i=1:blocksize:height
    for j=1:blocksize:width
        input=input_image(i:i+blocksize-1,j:j+blocksize-1);
        zigzag_blockbased=encoding_to_zigzag_scanned(input);
        zigzag_scanned=[zigzag_scanned; zigzag_blockbased];
    end
end
end
