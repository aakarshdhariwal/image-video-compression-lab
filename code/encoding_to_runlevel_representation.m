%x=[1,2,4,0,5,0,0,6,0,3];
function runlevel_representation=encoding_to_runlevel_representation(input_vector)
index=find(input_vector);
runlevel_representation=zeros(length(index),2);
k=1;
while k<length(index)+1
    
    
     if length(index)==1
         if length(input_vector)>1
             runlevel_representation(1,:)=[0,input_vector(index(1))];
        
         else
             runlevel_representation(1,:)=[0,input_vector];
         end
       
    else
        if input_vector(1)~=0 
         runlevel_representation(1,:)=[0,input_vector(index(1))];
        end

        if input_vector(1)==0
            n=length(input_vector(1:index(1)));
            run=n-1;
            level=input_vector(index(1));
            runlevel_representation(1,:)=[run, level];
        end   
            
   
        if index(k+1)-index(k)==1
            run=0;
            level=input_vector(index(k+1));
            runlevel_representation(k+1,:)=[run,level];
            
        else
            run=index(k+1)-index(k)-1;
            level=input_vector(index(k+1));
            runlevel_representation(k+1,:)=[run, level];
        end
    end
    k=k+1;
    if k==length(index)
        break;
    end
end
end

% function runlevel_representation=encoding_to_runlevel_representation(input_vector)
% L=length(input_vector);
% j=1;
% k=1;
% i=1;
% while i<2*L
%     comp=0;
%     for j=j:L
%         if j==L 
%             break
%         end;  
%          if input_vector(j)==0
%             comp=comp+1;
%         else
%             break
%         end;
%     end;
%         runlevel_representation(k)=comp;
%         runlevel_representation(k+1)=input_vector(j);
%         if j==L 
%             break
%         end;  
%         i=i+1;
%         k=k+2;
%         j=j+1;
%         if j==L 
%             if mod(L,2)==0 
%             runlevel_representation(k)=0;
%             runlevel_representation(k+1)=Input(j);
%             else
%             runlevel_representation(k)=0;    
%             runlevel_representation(k+1)=Input(j);
%                        end;
%              break
%         end;
%     end; 
% end
% 







%% test function
%input_vector=[1,2,4,0,5,0,0,6,0,3];
% input_vector=[0,1,0,0,2,0,3,4,5];
% %input_vector=4;
% input_vector=[8,0,0,0];
% index=[find(input_vector)];
% runlevel_representation=zeros(length(index),2);
% k=1;
% while k<length(index)+1
%     
%     
%     if length(index)==1
%          if length(input_vector)>1
%              runlevel_representation(1,:)=[0,input_vector(index(1))];
%         
%          else
%              runlevel_representation(1,:)=[0,input_vector];
%          end
%          
%         
%                 
%     else
%         if input_vector(1)~=0 
%          runlevel_representation(1,:)=[0,input_vector(index(1))];
%         end
% 
%         if input_vector(1)==0
%             n=length(input_vector(1:index(1)));
%             run=n-1;
%             level=input_vector(index(1));
%             runlevel_representation(1,:)=[run, level];
%         end   
%             
%    
%         if index(k+1)-index(k)==1
%             run=0;
%             level=input_vector(index(k+1));
%             runlevel_representation(k+1,:)=[run,level];
%             
%         else
%             run=index(k+1)-index(k)-1;
%             level=input_vector(index(k+1));
%             runlevel_representation(k+1,:)=[run, level];
%         end
%     end
%     k=k+1;
%     if k==length(index)
%         break;
%     end
% end
