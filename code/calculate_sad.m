function sad_value=calculate_sad(input_block1,input_block2)
diff=abs(input_block1-input_block2);
sad_value=sum(sum(diff));
end