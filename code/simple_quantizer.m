function quant_levels=simple_quantizer(input_image,quantizer_stepsize)
quant_levels=round(input_image*quantizer_stepsize);
end

