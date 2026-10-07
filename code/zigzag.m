function [B] = zigzag(M,N)
B = zeros(M,N);
count = 1;
B(1,1) = count;
v=1;
for k=1:M*N-1
    if k<=N
        if mod(k,2)==0
        j=k;
        for i=1:k
        B(i,j)=count;
        v=v+1;j=j-1;count=count+1;    
        end
        else
        i=k;
        for j=1:k   
        B(i,j)=count;
        v=v+1;i=i-1;count=count+1; 
        end
        end
    else
        if mod(k,2)==0
        p=mod(k,N); j=N;
        for i=p+1:N
        B(i,j)=count;
        v=v+1;j=j-1;count=count+1;
        end
        else
        p=mod(k,N);i=N;
        for j=p+1:N   
        B(i,j)=count;
        v=v+1;i=i-1;count=count+1; 
        end
        end
    end
end