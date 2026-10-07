%input_signal=load('input_signal_huffman.mat'); % data type is struct not array or cell
%input_signal=input_signal.input_signal;


function huffman_table= create_huffman_table_from_signal(input_signal)

[x,y,z]=unique(input_signal,'rows');
symbol_count=zeros(size(x,1),1); % column vector of size(x,1),1;
c=hist(z,size(x,1));
%value=(c.Values)';
% or 
%for i=1:size(z,1)
    %symbol_count(z(i))=symbol_count(z(i))+1;
%end

for i=1:size(x,1)
    
    symbol_count(i)=symbol_count(i)+c(i);
end

probability_matrix=zeros(size(x,1),size(x,2)+1);
prob=zeros(size(z,1),1);
for j=1:size(x,1)
    prob(j)=prob(j)+symbol_count(j)/size(input_signal,1);
    probability_matrix(j,:)=[prob(j) x(j,:)];
end
% or
%probability_matrix=[symbol_count./size(input_signal,1) x];
huffman_table=create_huffman_table_from_probability(probability_matrix);

end
