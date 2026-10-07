function motion_vector=get_motion_vector_for_block_3stepsearch(padded_input_image,padded_previous_image,blockstart_x,blockstart_y,blocksize,searchrange)
% motion_vector=get_motion_vector_for_block_3stepsearch(padded_input_image,
%   padded_previous_image,blockstart_x,blockstart_y,blocksize,searchrange)
%
% Same interface/return convention as get_motion_vector_for_block.m (full
% search), but performs a 3-step (multi-step) search instead of exhaustive
% full search (Exercise 4.6). Adapted from the step-halving block matching
% approach of Aroh Barjatya's "Block Matching Algorithms for Motion
% Estimation" reference implementation (see code/third_party/NOTICE.md).
% Per the lab manual (Sec. 4.4.1, Fig. 4.5): the initial step size is half
% the maximum search range; at each step all 9 points of a 3x3 grid around
% the current center are evaluated, the center moves to the best match, and
% the step size is halved regardless of where the best match was found,
% terminating once the step size reaches 1. (For search ranges other than
% the textbook example this takes more than three steps -- a "multi-step
% search", as the manual itself notes.)

current_block=padded_input_image(blockstart_y:(blockstart_y+blocksize-1),blockstart_x:(blockstart_x+blocksize-1));

step=max(round(searchrange/2),1);
d_m=0;
d_n=0;

while true
    offsets=[0 0;-step 0;step 0;0 -step;0 step;-step -step;-step step;step -step;step step];
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
    d_m=best_m;
    d_n=best_n;
    if step==1
        break;
    end
    step=max(floor(step/2),1);
end

motion_vector=[d_m,d_n];
end
