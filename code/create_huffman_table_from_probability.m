function huffman_table= create_huffman_table_from_probability(par_probability_matrix)

sorted_probability_matrix=sortrows(par_probability_matrix);
%[n,m]=size(sorted_probability_matrix);
nr_of_codewords=size(sorted_probability_matrix,1);
huffman_table=cell(nr_of_codewords,2);
huffman_tree=cell(nr_of_codewords,2);
for k=1:nr_of_codewords
    
    huffman_table{k,2}=[sorted_probability_matrix(k,2:end)];
   
end

for j=1:nr_of_codewords
     huffman_tree{j,1}=sorted_probability_matrix(j,1);
     %symbol_index=find(sorted_probability_matrix(j,1));
     huffman_tree{j,2}=j;
end

while(size(huffman_tree,1)>1)
    %show_huffman_tree(huffman_tree)
    %huffman_table{huffman_tree{1,2},1}='1';
    %huffman_table{huffman_tree{2,2},1}='0';
    %exercise 2.5
    % point 1
    for j=huffman_tree{1,2}
        huffman_table{j,1}=[1 huffman_table{j,1}];
    end
    for k=huffman_tree{2,2}
        huffman_table{k,1}=[0 huffman_table{k,1}];
    end
    % point 2-4
    new_huffman_tree=cell(size(huffman_tree,1)-1,2);
    new_huffman_tree{1,1}=huffman_tree{1,1}+huffman_tree{2,1};
    new_huffman_tree{1,2}=[ huffman_tree{1,2} huffman_tree{2,2}];
    
    for i=2:size(huffman_tree,1)-1
        new_huffman_tree{i,1}=huffman_tree{i+1,1};
        new_huffman_tree{i,2}=huffman_tree{i+1,2};
    end
    
    %show_huffman_tree(new_huffman_tree);
    
    
   huffman_tree=cell(size(new_huffman_tree));
   [new_probabilities, index]= sort([ new_huffman_tree{:,1}]);
    for x=1:length(new_probabilities)
        huffman_tree{x,1}=new_huffman_tree{index(x),1}; % or use new_probabilities??
        huffman_tree{x,2}=new_huffman_tree{index(x),2};
    end
    
   
    
        
    
    
end