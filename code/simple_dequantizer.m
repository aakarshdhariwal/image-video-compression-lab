function output_image=simple_dequantizer(quant_levels,quantizer_stepsize)
output_image=(1/quantizer_stepsize)*quant_levels;
end