%y=[0,15;0,1;3,-1;-1,-1;0,8;-1,-1;0,1;0,2;2,3;4,5;1,6;-1,-1];
function zigzag_scanned=blockbased_decoding_from_runlevel_representation(runlevel_representation,blocksize)
index=find(runlevel_representation(:,1)==-1);
%blocksize=2;
count=1;
%temp=decoding_from_runlevel_representation(y(7:11,:),2);
zigzag_scanned=zeros(size(index,1),blocksize*blocksize);
zigzag_scanned=[];
for i=1:size(index,1)
    temp=decoding_from_runlevel_representation(runlevel_representation(count:index(i)-1,:),blocksize);
    zigzag_scanned=[zigzag_scanned;temp];
    count=1+index(i);
    
end
end

    
    
