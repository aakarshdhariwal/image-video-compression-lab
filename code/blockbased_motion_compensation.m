function output_image=blockbased_motion_compensation(input_image,blocksize,searchrange,motion_vectors)
padded_reference=padarray(input_image,[searchrange,searchrange],'replicate','both');
output_image=zeros(size(input_image,1),size(input_image,2));

idx=1;

for block_outputy=1:blocksize:size(input_image,1)-blocksize+1
    for block_outputx=1:blocksize:size(input_image,2)-blocksize+1
        input_index_x=block_outputx+searchrange+motion_vectors(idx,2);
        input_index_y=block_outputy+searchrange+motion_vectors(idx,1);
        output_image(block_outputy:(block_outputy+blocksize-1),block_outputx:(block_outputx+blocksize-1))=padded_reference(input_index_y:(input_index_y+blocksize-1),input_index_x:(input_index_x+blocksize-1));
        idx=idx+1;
    end
end
        
        

end 