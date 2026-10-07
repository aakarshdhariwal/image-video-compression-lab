function motion_vectors=blockbased_motion_search_subpel(input_image,previous_image,blocksize,searchrange)
% motion_vectors=blockbased_motion_search_subpel(input_image,previous_image,blocksize,searchrange)
%
% Half-pel accurate motion estimation (lab manual Sec. 4.4.2, Exercises
% 4.9-4.11; a codec extension beyond the mandatory part of the lab).
%
% Two stages, as in real codecs: a full-pel search first (reusing the
% verified full search of get_motion_vector_for_block.m), then a refinement
% over the eight half-pel positions surrounding the best full-pel match,
% evaluated on a bilinearly interpolated reference frame.
%
% The returned motion vectors are expressed in HALF-PEL UNITS (i.e. integer
% multiples of a half pixel, so a full-pel displacement of 3 is returned as
% 6). Keeping them integral matters because they are entropy coded by the
% same Huffman stage as everything else, which matches symbols exactly.
% blockbased_motion_compensation_subpel.m consumes the same convention.

padded_current=padarray(input_image,[searchrange,searchrange],'replicate','both');
padded_reference=padarray(previous_image,[searchrange,searchrange],'replicate','both');
upsampled_reference=upsample_half_pel(padded_reference);
[upsampled_rows,upsampled_cols]=size(upsampled_reference);

half_pel_offsets=[0 0;-1 0;1 0;0 -1;0 1;-1 -1;-1 1;1 -1;1 1];

motion_vectors=[];
for blockstart_y=searchrange+1:blocksize:searchrange+size(input_image,1)-blocksize+1
    for blockstart_x=searchrange+1:blocksize:searchrange+size(input_image,2)-blocksize+1
        full_pel_vector=get_motion_vector_for_block(padded_current,padded_reference,blockstart_x,blockstart_y,blocksize,searchrange);

        current_block=padded_current(blockstart_y:(blockstart_y+blocksize-1),blockstart_x:(blockstart_x+blocksize-1));

        best_m=full_pel_vector(1)*2;
        best_n=full_pel_vector(2)*2;
        best_sad=Inf;
        for c=1:size(half_pel_offsets,1)
            candidate_m=best_m+half_pel_offsets(c,1);
            candidate_n=best_n+half_pel_offsets(c,2);

            row_start=2*(blockstart_y-1)+1+candidate_m;
            col_start=2*(blockstart_x-1)+1+candidate_n;
            if row_start<1 || col_start<1 || ...
               row_start+2*(blocksize-1)>upsampled_rows || col_start+2*(blocksize-1)>upsampled_cols
                continue;
            end
            candidate_block=upsampled_reference(row_start:2:row_start+2*(blocksize-1), ...
                                                col_start:2:col_start+2*(blocksize-1));
            sad=calculate_sad(current_block,candidate_block);
            if sad<best_sad
                best_sad=sad;
                refined_m=candidate_m;
                refined_n=candidate_n;
            end
        end
        if isinf(best_sad)
            refined_m=best_m;
            refined_n=best_n;
        end
        motion_vectors=[motion_vectors; refined_m refined_n];
    end
end
end
