function verify_fast_transform_equivalence()
% verify_fast_transform_equivalence()
%
% Asserts that the vectorized zigzag scan/inverse-scan used by the optimized
% codec produce exactly the same results as the reference implementations
% that the course's own verify_blockbased_*_zigzag_scanned harnesses check.

all_ok=true;
rand('seed',11);

for blocksize=[2 4 8]
    for trial=1:3
        blocks_down=2+trial;
        blocks_across=3+trial;
        height=blocks_down*blocksize;
        width=blocks_across*blocksize;
        test_image=round(rand(height,width)*100-50);

        reference_scan=blockbased_encoding_to_zigzag_scanned(test_image,blocksize);
        fast_scan=blockbased_encoding_to_zigzag_scanned_fast(test_image,blocksize);

        if ~isequal(reference_scan,fast_scan)
            printf('  blocksize %d trial %d: ZIGZAG SCAN DIFFERS\n',blocksize,trial);
            all_ok=false;
        end

        reference_image=blockbased_decoding_from_zigzag_scanned(fast_scan,blocksize,width,height);
        fast_image=blockbased_decoding_from_zigzag_scanned_fast(fast_scan,blocksize,width,height);

        if ~isequal(reference_image,fast_image)
            printf('  blocksize %d trial %d: INVERSE ZIGZAG SCAN DIFFERS\n',blocksize,trial);
            all_ok=false;
        end
        if ~isequal(fast_image,test_image)
            printf('  blocksize %d trial %d: ZIGZAG ROUND TRIP IS NOT LOSSLESS\n',blocksize,trial);
            all_ok=false;
        end
    end
end

if all_ok
    disp('fast zigzag scan is identical to the reference implementation: OK');
else
    disp('fast zigzag scan DIFFERS from the reference implementation!');
end
end
