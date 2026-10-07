function motion_vectors=blockbased_motion_search_3stepsearch(input_image,previous_image,blocksize,searchrange)
% Copy of blockbased_motion_search.m (Exercise 4.3) substituting the
% per-block search function with get_motion_vector_for_block_3stepsearch,
% per Exercise 4.6.
padded_current=padarray(input_image,[searchrange,searchrange],'replicate','both');
padded_reference=padarray(previous_image,[searchrange,searchrange],'replicate','both');

motion_vectors = [];
for blockstart_y=searchrange+1:blocksize:searchrange+size(input_image,1)-blocksize+1
    for blockstart_x=searchrange+1:blocksize:searchrange+size(input_image,2)-blocksize+1
        temp = get_motion_vector_for_block_3stepsearch(padded_current,padded_reference,blockstart_x,blockstart_y,blocksize,searchrange);
        motion_vectors = [motion_vectors; temp];
    end
end
