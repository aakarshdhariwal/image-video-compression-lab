function [bitstream signal]=decode_signal_from_huffman_bitstream_fast(bitstream,huffman_table,nr_of_symbols)
% [bitstream signal]=decode_signal_from_huffman_bitstream_fast(bitstream,huffman_table,nr_of_symbols)
%
% Vectorized, result-identical replacement for
% decode_signal_from_huffman_bitstream.m.
%
% The reference implementation re-reads the bitstream bit by bit for every
% candidate code word length of every symbol, which is far too slow for a
% full sequence. This version unpacks the whole bitstream into a bit vector
% once, then, for each code word length present in the table, evaluates in
% one vectorized pass which stream positions start a code word of that
% length. Because a Huffman code is a prefix code, at most one code word can
% match at any position, so this "symbol starting at position p" table is
% unambiguous and decoding reduces to walking the resulting chain.
%
% Equivalence against the reference implementation is asserted by
% verify_fast_huffman_equivalence.m.

if (nargin==2)
    nr_of_symbols=2^63;
end

total_length=double(bitstream(1));
read_start=double(bitstream(2));
nr_of_available_bits=total_length-read_start;
signal=[];
if nr_of_available_bits<=0
    return;
end

% Unpack the unread part of the stream into a plain bit vector.
k=read_start+(0:nr_of_available_bits-1);
word_index=4+floor(k/32);
bit_position=rem(k,32);
words=double(bitstream(word_index));
bits=mod(floor(words./(2.^bit_position)),2);

nr_of_huffman_entries=size(huffman_table,1);
huffman_length=zeros(1,nr_of_huffman_entries);
for i=1:nr_of_huffman_entries
    huffman_length(i)=length(huffman_table{i,1});
end
lengths_present=unique(huffman_length);
max_bits=max(lengths_present);

% symbol_at(p) = Huffman table row whose code word starts at bit p, or 0.
symbol_at=zeros(1,nr_of_available_bits);
length_at=zeros(1,nr_of_available_bits);

value=zeros(1,nr_of_available_bits);
for current_nr_of_bits=1:max_bits
    % value(p) becomes the integer value of bits(p : p+current_nr_of_bits-1)
    shifted=[bits(current_nr_of_bits:end) zeros(1,current_nr_of_bits-1)];
    value=value*2+shifted;
    if ~any(lengths_present==current_nr_of_bits)
        continue;
    end
    rows_with_this_length=find(huffman_length==current_nr_of_bits);
    code_values=zeros(1,numel(rows_with_this_length));
    for r=1:numel(rows_with_this_length)
        code_values(r)=polyval(huffman_table{rows_with_this_length(r),1},2);
    end
    last_valid_position=nr_of_available_bits-current_nr_of_bits+1;
    if last_valid_position<1
        break;
    end
    candidate=value(1:last_valid_position);
    [matched,location]=ismember(candidate,code_values);
    newly_matched=matched & (symbol_at(1:last_valid_position)==0);
    symbol_at(newly_matched)=rows_with_this_length(location(newly_matched));
    length_at(newly_matched)=current_nr_of_bits;
end

% Walk the chain of code words.
symbol_values=cell2mat(huffman_table(:,2));
decoded_rows=zeros(1,nr_of_available_bits);
nr_decoded=0;
position=1;
while position<=nr_of_available_bits && nr_decoded<nr_of_symbols
    row=symbol_at(position);
    if row==0
        break;
    end
    nr_decoded=nr_decoded+1;
    decoded_rows(nr_decoded)=row;
    position=position+length_at(position);
end

signal=symbol_values(decoded_rows(1:nr_decoded),:);
bitstream(2)=bitstream(2)+(position-1);
end
