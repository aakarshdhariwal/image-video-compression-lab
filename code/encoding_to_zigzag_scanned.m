function zigzag_scanned=encoding_to_zigzag_scanned(input_image)
width=size(input_image,2);
height=size(input_image,1);
permutation_matrix = generate_zigzag_permutation_matrix(width, height);
%ind = input_image(permutation_matrix);
zigzag_scanned=zeros(1,width*height);
zigzag_scanned(permutation_matrix)=input_image;
end
