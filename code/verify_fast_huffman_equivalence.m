function verify_fast_huffman_equivalence()
% verify_fast_huffman_equivalence()
%
% Asserts that the vectorized Huffman codec used by the codec pipeline
% (encode_signal_to_huffman_bitstream_fast.m /
%  decode_signal_from_huffman_bitstream_fast.m)
% produces exactly the same bitstream and exactly the same decoded signal as
% the reference course implementations
% (encode_signal_to_huffman_bitstream.m /
%  decode_signal_from_huffman_bitstream.m),
% which are themselves verified against the course's stored reference
% bitstream by verify_encode_decode_huffman.m.

all_ok=true;

% ---- Test 1: the course's own reference signal and Huffman table ----
load huffman_table.mat;
signal = [244 244;245 244;243 244;243 244;244 244;243 244;244 244;245 244;243 244;242 242;240 241];
all_ok = run_case('course reference signal', huffman_table, signal) && all_ok;

% ---- Test 2: randomised run-level style data over a generated table ----
rand('seed',7);
for trial=1:5
    nr_symbols=200+trial*50;
    runs=floor(rand(nr_symbols,1)*8);
    levels=round((rand(nr_symbols,1)-0.5)*20);
    test_signal=[runs levels];
    test_signal=[test_signal; -1 -1];            % end-of-block marker, as used by the codec
    generated_table=create_huffman_table_from_signal(test_signal);
    all_ok = run_case(sprintf('random trial %d (%d symbols)',trial,size(test_signal,1)), ...
                      generated_table,test_signal) && all_ok;
end

if all_ok
    disp('fast Huffman codec is bit-identical to the reference implementation: OK');
else
    disp('fast Huffman codec DIFFERS from the reference implementation!');
end
end

function ok=run_case(name,huffman_table,signal)
ok=true;

reference_bitstream=encode_signal_to_huffman_bitstream(bitstream_init(),huffman_table,signal);
fast_bitstream=encode_signal_to_huffman_bitstream_fast(bitstream_init(),huffman_table,signal);

if ~isequal(size(reference_bitstream),size(fast_bitstream)) || ~all(reference_bitstream==fast_bitstream)
    printf('  %s: ENCODED BITSTREAMS DIFFER\n',name);
    ok=false;
else
    printf('  %s: encoded bitstream identical (%d bits)\n',name,bitstream_get_length(fast_bitstream));
end

[~,reference_signal]=decode_signal_from_huffman_bitstream(reference_bitstream,huffman_table);
[~,fast_signal]=decode_signal_from_huffman_bitstream_fast(fast_bitstream,huffman_table);

if ~isequal(reference_signal,fast_signal)
    printf('  %s: DECODED SIGNALS DIFFER\n',name);
    ok=false;
end
if ~isequal(fast_signal,signal)
    printf('  %s: DECODED SIGNAL DOES NOT MATCH THE ORIGINAL\n',name);
    ok=false;
else
    printf('  %s: decode round-trip lossless\n',name);
end
end
