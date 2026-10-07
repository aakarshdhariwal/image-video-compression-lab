function motion_vector=get_motion_vector_for_block_logsearch(padded_input_image,padded_previous_image,blockstart_x,blockstart_y,blocksize,searchrange)
% motion_vector=get_motion_vector_for_block_logsearch(padded_input_image,
%   padded_previous_image,blockstart_x,blockstart_y,blocksize,searchrange)
%
% Same interface/return convention as get_motion_vector_for_block.m (full
% search), but performs a logarithmic (2D-log) search instead of exhaustive
% full search (Exercise 4.5). Adapted from the step-halving block matching
% approach of Aroh Barjatya's "Block Matching Algorithms for Motion
% Estimation" reference implementation (see code/third_party/NOTICE.md);
% the search-pattern/termination rule below follows the lab manual's exact
% description (Sec. 4.4.1, Fig. 4.4): a 5-point diamond is evaluated at each
% step, the step size is halved only once the best match is the center of
% the diamond or lies on the boundary of the search range, and the
% algorithm finishes with a full 8-neighbor-plus-center search once the
% step size reaches 1.

current_block=padded_input_image(blockstart_y:(blockstart_y+blocksize-1),blockstart_x:(blockstart_x+blocksize-1));

% initial step size = half the maximum search range (as a power of two)
step=2^floor(log2(max(searchrange,1)));
if step>searchrange
    step=step/2;
end
if step<1
    step=1;
end

d_m=0;
d_n=0;

while step>1
    diamond_offsets=[0 0;-step 0;step 0;0 -step;0 step];
    [best_m,best_n]=search_best_offset(current_block,padded_previous_image,blockstart_x,blockstart_y,d_m,d_n,diamond_offsets,searchrange,blocksize);
    centered = (best_m==d_m && best_n==d_n);
    at_boundary = (abs(best_m)==searchrange || abs(best_n)==searchrange);
    d_m=best_m;
    d_n=best_n;
    if centered || at_boundary
        step=step/2;
    end
end

% final step: full 3x3 neighborhood (8 neighbors + center) at step size 1
final_offsets=[0 0;-1 0;1 0;0 -1;0 1;-1 -1;-1 1;1 -1;1 1];
[d_m,d_n]=search_best_offset(current_block,padded_previous_image,blockstart_x,blockstart_y,d_m,d_n,final_offsets,searchrange,blocksize);

motion_vector=[d_m,d_n];
end

function [best_m,best_n]=search_best_offset(current_block,padded_previous_image,blockstart_x,blockstart_y,d_m,d_n,offsets,searchrange,blocksize)
% Evaluates SAD for (d_m,d_n)+each row of offsets, clipped to the search
% range, and returns the best (lowest-SAD) candidate. If no offset is found
% better than the current center, the center itself is returned.
best_sad=Inf;
best_m=d_m;
best_n=d_n;
for c=1:size(offsets,1)
    cm=d_m+offsets(c,1);
    cn=d_n+offsets(c,2);
    if abs(cm)>searchrange || abs(cn)>searchrange
        continue;
    end
    y_range=cm+blockstart_y;
    x_range=cn+blockstart_x;
    candidate_block=padded_previous_image(y_range:(y_range+blocksize-1),x_range:(x_range+blocksize-1));
    sad=calculate_sad(current_block,candidate_block);
    if sad<best_sad
        best_sad=sad;
        best_m=cm;
        best_n=cn;
    end
end
end
