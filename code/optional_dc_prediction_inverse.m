function zigzag_scanned=optional_dc_prediction_inverse(zigzag_scanned)
add=zigzag_scanned(1,1);
for i=2:size(zigzag_scanned,1)
    zigzag_scanned(i,1)=zigzag_scanned(i,1)+add;
    add=zigzag_scanned(i,1);
end
end