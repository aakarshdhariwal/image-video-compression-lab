function permutation_matrix = generate_zigzag_permutation_matrix(width, height)
permutation_matrix=zeros(width, height);
count=1;
cur_row=1;	cur_col=1;	cur_index=1;
while cur_row<=num_rows & cur_col<=num_cols
	if cur_row==1 & mod(cur_row+cur_col,2)==0 & cur_col~=num_cols
		permutation_matrix(cur_row,cur_col)=count;
		cur_col=cur_col+1;					%move right at the top
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_row==num_rows & mod(cur_row+cur_col,2)~=0 & cur_col~=num_cols
		permutation_matrix(cur_row,cur_col)=count;
		cur_col=cur_col+1;							%move right at the bottom
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_col==1 & mod(cur_row+cur_col,2)~=0 & cur_row~=num_rows
		permutation_matrix(cur_row,cur_col)=count;
		cur_row=cur_row+1;							%move down at the left
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_col==num_cols & mod(cur_row+cur_col,2)==0 & cur_row~=num_rows
		permutation_matrix(cur_row,cur_col)=count;
		cur_row=cur_row+1;							%move down at the right
		cur_index=cur_index+1;
        count=count+1
		
	elseif cur_col~=1 & cur_row~=num_rows & mod(cur_row+cur_col,2)~=0
		permutation_matrix(cur_row,cur_col)=count;
		cur_row=cur_row+1;		cur_col=cur_col-1;	%move diagonally left down
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_row~=1 & cur_col~=num_cols & mod(cur_row+cur_col,2)==0
		permutation_matrix(cur_row,cur_col)=count;
		cur_row=cur_row-1;		cur_col=cur_col+1;	%move diagonally right up
		cur_index=cur_index+1;
        count=count+1;
		
	elseif cur_row==num_rows & cur_col==num_cols	%obtain the bottom right element
        permutation_matrix(end)=count;							%end of the operation
		break										%terminate the operation
    end
end