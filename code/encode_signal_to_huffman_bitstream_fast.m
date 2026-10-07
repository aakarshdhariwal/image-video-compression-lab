function [bitstream]=encode_signal_to_huffman_bitstream_fast(bitstream,huffman_table,signal)
% [bitstream]=encode_signal_to_huffman_bitstream_fast(bitstream,huffman_table,signal)
%
% Vectorized, bit-identical replacement for encode_signal_to_huffman_bitstream.m.
%
% The course-provided bitstream writer (bitstream_append_bits.m) sets one bit
% at a time with bitset and is documented in its own header as "terribly
% slow"; combined with a per-symbol table lookup that makes a 5-frame CIF
% rate-distortion sweep impractical (hours). This version looks every symbol
% up in one vectorized ismember call, concatenates all code words into a
% single bit vector, and packs that vector into the uint32 bitstream words
% arithmetically, producing exactly the same bitstream.
%
% Equivalence against the reference implementation is asserted by
% verify_fast_huffman_equivalence.m.

huffman_table_lookup=cell2mat(huffman_table(:,2));
[found,table_row]=ismember(signal,huffman_table_lookup,'rows');
if any(~found)
    error('encode_signal_to_huffman_bitstream_fast: symbol missing from the Huffman table');
end

code_words=huffman_table(:,1);
all_bits=[code_words{table_row}];
nr_of_bits=numel(all_bits);
if nr_of_bits==0
    return;
end

% Bit k (0-based, counted from the start of the stream) lives in word
% 4+floor(k/32) at bit position rem(k,32), matching bitstream_append_bits.m.
start_bit=double(bitstream(3));
k=start_bit+(0:nr_of_bits-1);
word_index=4+floor(k/32);
bit_position=rem(k,32);

% bitstream_append_bits.m always performs one final word write after its bit
% loop, so when the data happens to end exactly on a 32-bit boundary it
% leaves one extra zero word at the end of the array. Reproduce that here so
% the two implementations agree element for element, not just bit for bit.
final_write_pointer=start_bit+nr_of_bits;
last_word=max(max(word_index),4+floor(final_write_pointer/32));
if numel(bitstream)<last_word
    bitstream(last_word)=uint32(0);
end

% New bits never collide with bits already present in the first partial word
% (they sit strictly above the old write pointer), so summing is equivalent
% to OR-ing them in.
contribution=double(all_bits).*(2.^bit_position);
packed=accumarray(word_index(:),contribution(:),[last_word 1]);
packed(1:3)=0;   % never touch the length/read/write header words
existing=double(bitstream(1:last_word));
bitstream(1:last_word)=uint32(existing(:)+packed);

bitstream(3)=bitstream(3)+nr_of_bits;
if bitstream(1)<bitstream(3)
    bitstream(1)=bitstream(3);
end
end
