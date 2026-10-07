function result=benchmark_codec(sequence,qp_values,options,number_of_frames,transform_blocksize,me_blocksize,me_searchrange)
% result=benchmark_codec(sequence,qp_values,options,number_of_frames,
%                        transform_blocksize,me_blocksize,me_searchrange)
%
% Runs encoder_opt/decoder_opt over a list of quantization parameters and
% returns measured rate-distortion data for one codec configuration.
%
% Unlike the course-provided get_dr_result.m -- which derives the "rate"
% from the size of the saved .mat container, and so measures MATLAB's file
% format as much as the codec -- this harness reports the true number of
% entropy coded bits produced by the encoder, and reports SSIM alongside
% PSNR.
%
% result fields (one entry per QP):
%   .qp .rate_kbps .bits .psnr .ssim .enc_time .dec_time

if nargin<4 || isempty(number_of_frames);    number_of_frames=5;    end
if nargin<5 || isempty(transform_blocksize); transform_blocksize=8; end
if nargin<6 || isempty(me_blocksize);        me_blocksize=16;       end
if nargin<7 || isempty(me_searchrange);      me_searchrange=8;      end

width=352;
height=288;
frame_rate=12.5;   % the rate convention used by the course's get_dr_result.m

coded_file=[tempname() '.mat'];
recon_file=[tempname() '.yuv'];

result=struct();
result.qp=qp_values;
result.sequence=sequence;
result.options=options;
result.bits=zeros(1,numel(qp_values));
result.rate_kbps=zeros(1,numel(qp_values));
result.psnr=zeros(1,numel(qp_values));
result.ssim=zeros(1,numel(qp_values));
result.enc_time=zeros(1,numel(qp_values));
result.dec_time=zeros(1,numel(qp_values));

for k=1:numel(qp_values)
    qp=qp_values(k);

    if exist(recon_file,'file'); delete(recon_file); end

    tic;
    coded_bits=encoder_opt(sequence,coded_file,width,height,number_of_frames, ...
                           transform_blocksize,qp,me_blocksize,me_searchrange,options);
    enc_time=toc;

    tic;
    decoder_opt(coded_file,recon_file);
    dec_time=toc;

    psnr_values=get_psnr_for_sequence(sequence,recon_file,width,height,number_of_frames);
    ssim_value=get_ssim_for_sequence(sequence,recon_file,width,height,number_of_frames);

    result.bits(k)=coded_bits;
    result.rate_kbps(k)=coded_bits*frame_rate/number_of_frames/1024;
    result.psnr(k)=psnr_values(1);
    result.ssim(k)=ssim_value;
    result.enc_time(k)=enc_time;
    result.dec_time(k)=dec_time;

    printf('  QP %3d | %8.1f kbit/s | PSNR %6.2f dB | SSIM %6.4f | enc %6.1fs dec %5.1fs\n', ...
           qp,result.rate_kbps(k),result.psnr(k),result.ssim(k),enc_time,dec_time);
    fflush(stdout);
end

if exist(coded_file,'file'); delete(coded_file); end
if exist(recon_file,'file'); delete(recon_file); end
end
