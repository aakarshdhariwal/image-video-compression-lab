function upsampled_image=upsample_half_pel(input_image)
% upsampled_image=upsample_half_pel(input_image)
%
% Bilinear 2x upsampling onto the half-pel grid, used by the sub-pixel
% motion estimation/compensation extension (lab manual Sec. 4.4.2).
%
% Sample (i,j) of input_image lands at (2i-1, 2j-1) of upsampled_image;
% the interleaved positions are the horizontal, vertical and diagonal
% half-pel interpolations of their full-pel neighbours. The last row/column
% replicate the edge so that the output is exactly 2*rows x 2*cols and a
% block read at any valid full-pel position with a half-pel offset stays in
% bounds.
[rows,cols]=size(input_image);
upsampled_image=zeros(2*rows,2*cols);

% full-pel positions
upsampled_image(1:2:end,1:2:end)=input_image;

% horizontal half-pel positions
horizontal=(input_image(:,1:end-1)+input_image(:,2:end))/2;
upsampled_image(1:2:end,2:2:end-2)=horizontal;
upsampled_image(1:2:end,end)=input_image(:,end);

% vertical half-pel positions
vertical=(input_image(1:end-1,:)+input_image(2:end,:))/2;
upsampled_image(2:2:end-2,1:2:end)=vertical;
upsampled_image(end,1:2:end)=input_image(end,:);

% diagonal half-pel positions
diagonal=(input_image(1:end-1,1:end-1)+input_image(1:end-1,2:end)+ ...
          input_image(2:end,1:end-1)+input_image(2:end,2:end))/4;
upsampled_image(2:2:end-2,2:2:end-2)=diagonal;
upsampled_image(2:2:end-2,end)=vertical(:,end);
upsampled_image(end,2:2:end-2)=horizontal(end,:);
upsampled_image(end,end)=input_image(end,end);
end
