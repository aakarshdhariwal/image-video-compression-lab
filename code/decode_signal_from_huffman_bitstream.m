function [bitstream signal]=decode_signal_from_huffman_bitstream(bitstream,huffman_table,nr_of_symbols)
% [bitstream signal]=decode_signal_from_huffman_bitstream(bitstream,huffman_table,nr_of_symbols)
%
% Recreates the original input signal from a Huffman-coded bitstream using
% huffman_table (see Exercise 2.9/2.10 of the lab manual for the exact
% algorithm this implements).
if (nargin==2)
    nr_of_symbols=2^63;
end
nr_of_huffman_entries=size(huffman_table,1);
huffman_length=zeros(1,nr_of_huffman_entries);
for i=1:nr_of_huffman_entries
    huffman_length(i)=huffman_length(i)+length(huffman_table{i,1});
end

min_bits=min(huffman_length);
max_bits=max(huffman_length);

signal=[];
% NOTE: a plain "for j=1:nr_of_symbols" cannot be used here because the
% default nr_of_symbols is 2^63 ("decode the whole bitstream"), which is not
% a constructible range in Octave; this equivalent while loop avoids
% materialising it.
j=0;
while j<nr_of_symbols
    j=j+1;

    symbol_found=false;  % no symbol has been found when starting the search
    current_nr_of_bits=min_bits; % look for the shortest huffman code

    while(current_nr_of_bits<=max_bits && symbol_found==false)
        [this_huffman new_bitstream]=bitstream_read_bits(bitstream,current_nr_of_bits);
        if (isempty(this_huffman))
            fprintf('End of the bitstream has been reached\n');
            break;
        end

        for symbol_row=find(huffman_length==current_nr_of_bits) % gives the index where the function finds the match
            if (isequal(this_huffman(1:current_nr_of_bits),huffman_table{symbol_row,1}))
                this_symbol=huffman_table{symbol_row,2};
                signal=[signal; this_symbol];
                bitstream=new_bitstream;
                symbol_found=true;
                break
            end
        end
        current_nr_of_bits=current_nr_of_bits+1;
    end

    if (symbol_found==false)
        break;
    end
end

if (nr_of_symbols~=2^63) && (size(signal,1)<nr_of_symbols)
    fprintf('Error Message: fewer than nr_of_symbols hyper symbols could be decoded\n');
end
end
