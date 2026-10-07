function [bitstream]=encode_signal_to_huffman_bitstream(bitstream,huffman_table,signal)
huffman_table_lookup=cell2mat(huffman_table(:,2));
for idx=1:size(signal,1)
    find_col1=find(huffman_table_lookup(:,1)==signal(idx,1));
    find_col2=find(huffman_table_lookup(find_col1,2)==signal(idx,2));
    position_in_huffman_table=find_col1(find_col2);
    vector=huffman_table{position_in_huffman_table,1};
    bitstream=bitstream_append_bits(bitstream,vector);
end

    
    
    
end

%bitstream=bitstream_init();

