image=imread('flowergarden_cif_frame1.tif');
quality=10:10:100;
D=[];
R=[];
for i=1:length(quality)
    imwrite(image,'test.jpeg','jpeg','quality',quality(i));
    file_size=get_image_filesize('test.jpeg');
    R(i)=round(file_size/(size(image,1)*size(image,2))); %bits per pixels
    input_image=imread('test.jpeg');
    D(i)=psnr_of_frame(image,input_image);
    
    plot(D(1:i),R(1:i)); 
    hold on;
    pause(0.5)
    
end



figure();
imshow(image);
figure();
imshow(input_image);