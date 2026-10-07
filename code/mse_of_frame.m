function output_mse=mse_of_frame(original_image,distorted_image)

mse=original_image-distorted_image;
output_mse=mean(mean(mse.^2));
end
        
        

