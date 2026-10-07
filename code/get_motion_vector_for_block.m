function motion_vector=get_motion_vector_for_block(padded_input_image,padded_previous_image,blockstart_x,blockstart_y,blocksize,searchrange)

current_block=padded_input_image(blockstart_y:(blockstart_y+blocksize-1),blockstart_x:(blockstart_x+blocksize-1));
%current_block=padded_input_image(blockstart_x-1:blocksize,blocksize*blockstart_y-1:blockstart_y*blocksize);
sad_value=Inf;
for d_m=-searchrange:searchrange %blockstart_y-blocksize:blockstr_y+block
    for d_n=-searchrange:searchrange %blockstart_x-searchrange:blockstr_x+searchrange
        x_range=d_n+blockstart_x;
        y_range=d_m+blockstart_y;
        candidate_block=padded_previous_image(y_range:(y_range+blocksize-1),x_range:(x_range+blocksize-1));
        sad = calculate_sad(current_block, candidate_block);
        if sad < sad_value
            sad_value = sad;
            motion_vector = [d_m,d_n];
        end
    end
end

end
