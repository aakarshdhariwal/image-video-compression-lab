% x=[0,2;0,1;2,3;4,5;1,6];
% y=sum(x(:,1));
% %x=[0,8];
% x=[1,1;2,2;1,3;0,4;0,5];
%runlevel_representation=x;
%blocksize=2;
function output_vector=decoding_from_runlevel_representation(runlevel_representation,blocksize)
output_vector=[zeros(1,blocksize*blocksize)];
count=1;
%output_vector=[];
for i=1:size(runlevel_representation,1)
    if runlevel_representation(i,1)==0
        %output_vector=[output_vector,runlevel_representation(i,2)];
        output_vector(count)=runlevel_representation(i,2);
        count=count+1;
            
    else
          %z=zeros(1,runlevel_representation(i,1));
          %output_vector=[output_vector,z,runlevel_representation(i,2)];  
         output_vector(count:count+runlevel_representation(i,1))=0;
         output_vector(count+runlevel_representation(i,1))=runlevel_representation(i,2);
         count=count+runlevel_representation(i,1)+1;
     
    end
    
end
end

            
        
        