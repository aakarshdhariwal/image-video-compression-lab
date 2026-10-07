function final_decoder(coded_file,decoded_sequence_yuv)
% final_decoder(coded_file,decoded_sequence_yuv)
%
% Uniform-interface wrapper required by Exercise 6.15, pairing with
% final_encoder.m. decoder_basic does not need the fixed parameters passed
% explicitly since they are saved into coded_file by the encoder.
decoder_basic(coded_file,decoded_sequence_yuv);
end
