function motion_vectors=blockbased_motion_search(input_image,previous_image,blocksize,searchrange)
padded_current=padarray(input_image,[searchrange,searchrange],'replicate','both');
padded_reference=padarray(previous_image,[searchrange,searchrange],'replicate','both');
n=searchrange-blocksize+1;
%full_search_size=size(input_image)/(searchrange^2);
%no_of_motion_vectors=full_search_size*(n^2);

motion_vectors = [];
for blockstart_y=searchrange+1:blocksize:searchrange+size(input_image,1)-blocksize+1
    for blockstart_x=searchrange+1:blocksize:searchrange+size(input_image,2)-blocksize+1
        temp = get_motion_vector_for_block(padded_current,padded_reference,blockstart_x,blockstart_y,blocksize,searchrange);
        motion_vectors = [motion_vectors; temp];
    
    end
end

