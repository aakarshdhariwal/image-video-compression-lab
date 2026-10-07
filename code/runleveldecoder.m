x=[0,2;0,1;2,3;4,5;1,6];
b=[];
for i=1:size(x,1)
    if x(i,1)==0
        b=[b,x(i,2)];
    else
        z=zeros(1,x(i,1));
        b=[b,z,x(i,2)];
    end
end

            
        
        