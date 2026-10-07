function output_image=blockbased_motion_compensation_subpel(input_image,blocksize,searchrange,motion_vectors)
% output_image=blockbased_motion_compensation_subpel(input_image,blocksize,searchrange,motion_vectors)
%
% Half-pel accurate motion compensation (Exercise 4.12; codec extension).
% Same role as blockbased_motion_compensation.m, but the motion vectors are
% in half-pel units and the prediction is read from a bilinearly
% interpolated reference frame (upsample_half_pel.m).
padded_reference=padarray(input_image,[searchrange,searchrange],'replicate','both');
upsampled_reference=upsample_half_pel(padded_reference);
[upsampled_rows,upsampled_cols]=size(upsampled_reference);

output_image=zeros(size(input_image,1),size(input_image,2));

idx=1;
for block_outputy=1:blocksize:size(input_image,1)-blocksize+1
    for block_outputx=1:blocksize:size(input_image,2)-blocksize+1
        % position of this block inside the padded reference, in full pel
        padded_y=block_outputy+searchrange;
        padded_x=block_outputx+searchrange;

        row_start=2*(padded_y-1)+1+motion_vectors(idx,1);
        col_start=2*(padded_x-1)+1+motion_vectors(idx,2);

        row_start=max(min(row_start,upsampled_rows-2*(blocksize-1)),1);
        col_start=max(min(col_start,upsampled_cols-2*(blocksize-1)),1);

        output_image(block_outputy:(block_outputy+blocksize-1),block_outputx:(block_outputx+blocksize-1))= ...
            upsampled_reference(row_start:2:row_start+2*(blocksize-1), ...
                                col_start:2:col_start+2*(blocksize-1));
        idx=idx+1;
    end
end
end
