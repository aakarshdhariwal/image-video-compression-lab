function permutation_matrix = generate_zigzag_permutation_matrix(width, height)
permutation_matrix=zeros(height, width);
count=1;
cur_row=1;	cur_col=1;	cur_index=1;
while cur_row<=height & cur_col<=width
	if cur_row==1 & mod(cur_row+cur_col,2)==0 & cur_col~=width
		permutation_matrix(cur_row,cur_col)=count;
		cur_col=cur_col+1;					%move right at the top
		%cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_row==height & mod(cur_row+cur_col,2)~=0 & cur_col~=width
		permutation_matrix(cur_row,cur_col)=count;
		cur_col=cur_col+1;							%move right at the bottom
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_col==1 & mod(cur_row+cur_col,2)~=0 & cur_row~=height
		permutation_matrix(cur_row,cur_col)=count;
		cur_row=cur_row+1;							%move down at the left
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_col==width & mod(cur_row+cur_col,2)==0 & cur_row~=height
		permutation_matrix(cur_row,cur_col)=count;
		cur_row=cur_row+1;							%move down at the right
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_col~=1 & cur_row~=height & mod(cur_row+cur_col,2)~=0
		permutation_matrix(cur_row,cur_col)=count;
		cur_row=cur_row+1;		cur_col=cur_col-1;	%move diagonally left down
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_row~=1 & cur_col~=width & mod(cur_row+cur_col,2)==0
		permutation_matrix(cur_row,cur_col)=count;
		cur_row=cur_row-1;		cur_col=cur_col+1;	%move diagonally right up
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_row==height & cur_col==width	%obtain the bottom right element
        permutation_matrix(end)=count;							%end of the operation
		break										%terminate the operation
    end
end