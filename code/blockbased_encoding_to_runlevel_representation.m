function runlevel_representation=blockbased_encoding_to_runlevel_representation(zigzag_scanned)
runlevel_representation=[];
for i=1:size(zigzag_scanned,1)
    out=encoding_to_runlevel_representation(zigzag_scanned(i,:));
    runlevel_representation=[runlevel_representation;[out]];
    runlevel_representation=[runlevel_representation;[-1,-1]];
end
end
 

%% test
%input_vector=[1,2,4,0,5,0,0,6,0,3];
% input_vector=[0,1,0,0,2,0,3,4,5];
% zigzag_scanned=[[1,2,4,0,5,0,0,6,0,3];[0,1,0,0,2,0,3,4,5,0]];
% zigzag_scanned=[[1,2,4,0,5,0,0,6,0,3];[0,1,0,0,2,0,3,4,5,0];[8,0,0,0,0,0,0,0,0,0]];
% runlevel_representation=[];
% for i=1:size(zigzag_scanned,1)
%     out=encoding_to_runlevel_representation(zigzag_scanned(i,:));
%     runlevel_representation=[runlevel_representation;[out]];
%     runlevel_representation=[runlevel_representation;[-1,-1]];
% end