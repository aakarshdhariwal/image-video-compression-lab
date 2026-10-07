function output_image=deblock_frame(input_image,blocksize,qp)
% output_image=deblock_frame(input_image,blocksize,qp)
%
% In-loop deblocking filter (codec extension, beyond the base lab
% requirements). Smooths the transform-block edges that blockwise DCT plus
% coarse quantization leaves behind, using the conditional weak-filter idea
% from H.264/AVC's deblocking stage (ITU-T H.264 Sec. 8.7): a block edge is
% only filtered where the step across it is small enough to be a coding
% artifact rather than a real image edge, and the filter strength scales
% with the quantizer.
%
% For pixels p1 p0 | q0 q1 straddling an edge, the correction
%   delta = clip((q0-p0)/4)  applied as p0+delta, q0-delta
% is applied only where |p0-q0| < alpha, |p1-p0| < beta and |q1-q0| < beta.
% Thresholds are tied to the actual AC quantizer step for this QP, so the
% filter does nothing at fine quantization and strengthens as QP grows.
%
% Applied identically inside the encoder's reconstruction loop and in the
% decoder, so both stay in sync (a true in-loop filter, not a post-filter).

quantisation_matrix=get_quantisation_matrix(qp,blocksize);
quantizer_step=quantisation_matrix(2,2);   % AC step size for this QP
alpha=3.0*quantizer_step;
beta=1.5*quantizer_step;

output_image=input_image;
[rows,cols]=size(input_image);

% ---- vertical block edges (filter horizontally across columns) ----
for edge_col=blocksize+1:blocksize:cols
    if edge_col-2<1 || edge_col+1>cols
        continue;
    end
    p1=output_image(:,edge_col-2);
    p0=output_image(:,edge_col-1);
    q0=output_image(:,edge_col);
    q1=output_image(:,edge_col+1);

    filter_here=(abs(p0-q0)<alpha) & (abs(p1-p0)<beta) & (abs(q1-q0)<beta);
    delta=(q0-p0)/4;
    delta=max(min(delta,quantizer_step/2),-quantizer_step/2);
    delta(~filter_here)=0;

    output_image(:,edge_col-1)=p0+delta;
    output_image(:,edge_col)=q0-delta;
end

% ---- horizontal block edges (filter vertically across rows) ----
for edge_row=blocksize+1:blocksize:rows
    if edge_row-2<1 || edge_row+1>rows
        continue;
    end
    p1=output_image(edge_row-2,:);
    p0=output_image(edge_row-1,:);
    q0=output_image(edge_row,:);
    q1=output_image(edge_row+1,:);

    filter_here=(abs(p0-q0)<alpha) & (abs(p1-p0)<beta) & (abs(q1-q0)<beta);
    delta=(q0-p0)/4;
    delta=max(min(delta,quantizer_step/2),-quantizer_step/2);
    delta(~filter_here)=0;

    output_image(edge_row-1,:)=p0+delta;
    output_image(edge_row,:)=q0-delta;
end

output_image(output_image<0)=0;
output_image(output_image>1)=1;
end
