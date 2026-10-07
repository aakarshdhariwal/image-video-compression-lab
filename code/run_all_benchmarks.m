function run_all_benchmarks(stage,output_root)
% run_all_benchmarks(stage,output_root)
%
% Full measurement suite for the codec. Every number and figure in the
% repository's README is produced by this script.
%
% stage: 'verify' | 'dr' | 'me' | 'ablation' | 'sequences' | 'jpeg' |
%        'visuals' | 'all'
% output_root: repository root; results are written to
%        <output_root>/results/data and <output_root>/results/figures

if nargin<1 || isempty(stage); stage='all'; end
if nargin<2 || isempty(output_root); output_root='..'; end

warning('off','all');
set(0,'DefaultFigureVisible','off');
setup_codec();

data_dir=fullfile(output_root,'results','data');
figure_dir=fullfile(output_root,'results','figures');
if ~exist(data_dir,'dir');   mkdir(data_dir);   end
if ~exist(figure_dir,'dir'); mkdir(figure_dir); end

qp_values=[6 10 15 20 30];
main_sequence='flowergarden_short_cif.yuv';
all_sequences={'flowergarden_short_cif.yuv','rugby_short_cif.yuv', ...
               'shuttle_short_cif.yuv','vimto_short_cif.yuv'};

run_all=strcmp(stage,'all');

% ------------------------------------------------------------------
if run_all || strcmp(stage,'verify')
    printf('\n===== equivalence of the optimized code paths =====\n');
    verify_fast_huffman_equivalence();
    verify_fast_transform_equivalence();
    fflush(stdout);
end

% ------------------------------------------------------------------
if run_all || strcmp(stage,'dr')
    printf('\n===== intra-only vs hybrid coding (%s) =====\n',main_sequence);

    printf(' intra only (every frame coded independently):\n');
    intra=benchmark_codec(main_sequence,qp_values,struct('intra_only',true));

    printf(' hybrid (I-frame + motion compensated P-frames, full search):\n');
    hybrid=benchmark_codec(main_sequence,qp_values,struct('me_strategy','full'));

    save(fullfile(data_dir,'dr_intra_vs_hybrid.mat'),'intra','hybrid','qp_values');

    make_plot({intra,hybrid},{'Intra only','Hybrid (full search ME)'}, ...
              'psnr','Rate (kbit/s)','PSNR_Y (dB)', ...
              'Intra vs hybrid coding - flowergarden', ...
              fullfile(figure_dir,'dr_intra_vs_hybrid_psnr.png'));
    make_plot({intra,hybrid},{'Intra only','Hybrid (full search ME)'}, ...
              'ssim','Rate (kbit/s)','SSIM', ...
              'Intra vs hybrid coding - flowergarden', ...
              fullfile(figure_dir,'dr_intra_vs_hybrid_ssim.png'));
end

% ------------------------------------------------------------------
if run_all || strcmp(stage,'me')
    printf('\n===== motion estimation strategies (%s) =====\n',main_sequence);
    strategies={'full','3step','log'};
    labels={'Full search','3-step search','Logarithmic search'};
    me_results=cell(1,numel(strategies));
    for s=1:numel(strategies)
        printf(' %s:\n',labels{s});
        me_results{s}=benchmark_codec(main_sequence,qp_values,struct('me_strategy',strategies{s}));
    end
    save(fullfile(data_dir,'me_strategies.mat'),'me_results','strategies','labels','qp_values');

    make_plot(me_results,labels,'psnr','Rate (kbit/s)','PSNR_Y (dB)', ...
              'Motion estimation strategies - flowergarden', ...
              fullfile(figure_dir,'me_strategies_psnr.png'));
    make_time_plot(me_results,labels,qp_values, ...
              fullfile(figure_dir,'me_strategies_time.png'));
end

% ------------------------------------------------------------------
if run_all || strcmp(stage,'ablation')
    printf('\n===== extension ablation (%s) =====\n',main_sequence);
    configurations={ ...
        struct('me_strategy','full'), ...
        struct('me_strategy','full','rdo',true), ...
        struct('me_strategy','full','deblock',true), ...
        struct('me_strategy','subpel'), ...
        struct('me_strategy','subpel','rdo',true,'deblock',true)};  %#ok
    % (labels below must stay aligned with this list)
    labels={'Baseline','+ RD-optimized decisions','+ In-loop deblocking', ...
            '+ Half-pel ME','All extensions'};
    ablation=cell(1,numel(configurations));
    for c=1:numel(configurations)
        printf(' %s:\n',labels{c});
        ablation{c}=benchmark_codec(main_sequence,qp_values,configurations{c});
    end
    save(fullfile(data_dir,'ablation.mat'),'ablation','labels','qp_values');

    make_plot(ablation,labels,'psnr','Rate (kbit/s)','PSNR_Y (dB)', ...
              'Effect of each extension - flowergarden', ...
              fullfile(figure_dir,'ablation_psnr.png'));
    make_plot(ablation,labels,'ssim','Rate (kbit/s)','SSIM', ...
              'Effect of each extension - flowergarden', ...
              fullfile(figure_dir,'ablation_ssim.png'));
end

% ------------------------------------------------------------------
if run_all || strcmp(stage,'sequences')
    printf('\n===== all four test sequences =====\n');
    sequence_results=cell(1,numel(all_sequences));
    best_options=struct('me_strategy','subpel','rdo',true,'deblock',true);
    for s=1:numel(all_sequences)
        printf(' %s:\n',all_sequences{s});
        sequence_results{s}=benchmark_codec(all_sequences{s},qp_values,best_options);
    end
    save(fullfile(data_dir,'sequences.mat'),'sequence_results','all_sequences','qp_values');

    labels=strrep(strrep(all_sequences,'_short_cif.yuv',''),'_',' ');
    make_plot(sequence_results,labels,'psnr','Rate (kbit/s)','PSNR_Y (dB)', ...
              'Fully extended codec across all test sequences', ...
              fullfile(figure_dir,'sequences_psnr.png'));
    make_plot(sequence_results,labels,'ssim','Rate (kbit/s)','SSIM', ...
              'Fully extended codec across all test sequences', ...
              fullfile(figure_dir,'sequences_ssim.png'));
end

% ------------------------------------------------------------------
if run_all || strcmp(stage,'jpeg')
    printf('\n===== external JPEG baseline (%s) =====\n',main_sequence);
    jpeg_quality=[20 40 60 75 90];
    jpeg=benchmark_jpeg_baseline(main_sequence,jpeg_quality);
    printf(' this codec, fully extended:\n');
    ours=benchmark_codec(main_sequence,qp_values,struct('me_strategy','subpel','rdo',true,'deblock',true));
    printf(' this codec, intra only:\n');
    ours_intra=benchmark_codec(main_sequence,qp_values,struct('intra_only',true));
    save(fullfile(data_dir,'jpeg_baseline.mat'),'jpeg','ours','ours_intra','jpeg_quality','qp_values');

    make_plot({jpeg,ours_intra,ours}, ...
              {'JPEG (per frame, imwrite)','This codec, intra only','This codec, fully extended'}, ...
              'psnr','Rate (kbit/s)','PSNR_Y (dB)', ...
              'Comparison against a per-frame JPEG baseline - flowergarden', ...
              fullfile(figure_dir,'jpeg_baseline_psnr.png'));
end

% ------------------------------------------------------------------
if run_all || strcmp(stage,'visuals')
    printf('\n===== visual results =====\n');
    make_visuals(main_sequence,figure_dir);
end

printf('\nDone.\n');
end


% ======================================================================
function result=benchmark_intra_only(sequence,qp_values)
% Intra-only operating point: encoder_basic_intra/decoder_basic_intra, but
% measured with the same true-bit-count/PSNR/SSIM harness.
width=352; height=288; number_of_frames=5; transform_blocksize=8; frame_rate=12.5;
coded_file=[tempname() '.mat'];
recon_file=[tempname() '.yuv'];

result=struct();
result.qp=qp_values;
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
    coded_bits=encoder_basic_intra(sequence,coded_file,width,height,number_of_frames,transform_blocksize,qp);
    enc_time=toc;
    tic;
    decoder_basic_intra(coded_file,recon_file);
    dec_time=toc;

    psnr_values=get_psnr_for_sequence(sequence,recon_file,width,height,number_of_frames);
    result.bits(k)=coded_bits;
    result.rate_kbps(k)=coded_bits*frame_rate/number_of_frames/1024;
    result.psnr(k)=psnr_values(1);
    result.ssim(k)=get_ssim_for_sequence(sequence,recon_file,width,height,number_of_frames);
    result.enc_time(k)=enc_time;
    result.dec_time(k)=dec_time;
    printf('  QP %3d | %8.1f kbit/s | PSNR %6.2f dB | SSIM %6.4f | enc %6.1fs dec %5.1fs\n', ...
           qp,result.rate_kbps(k),result.psnr(k),result.ssim(k),enc_time,dec_time);
    fflush(stdout);
end
if exist(coded_file,'file'); delete(coded_file); end
if exist(recon_file,'file'); delete(recon_file); end
end


% ======================================================================
function make_plot(results,labels,field,x_label,y_label,plot_title,filename)
% Plotting is wrapped so that a rendering problem can never destroy
% measurement data -- the numbers are always saved to results/data first.
markers={'-o','-s','-^','-d','-v','-p'};
try
    figure_handle=new_offscreen_figure();
    hold on;
    for r=1:numel(results)
        y=getfield(results{r},field);
        plot(results{r}.rate_kbps,y,markers{mod(r-1,numel(markers))+1},'LineWidth',1.6,'MarkerSize',6);
    end
    grid on;
    xlabel(x_label);
    ylabel(y_label);
    title(plot_title);
    legend(labels,'Location','SouthEast');
    print(filename,'-dpng','-r120');
    close(figure_handle);
    printf('  wrote %s\n',filename);
catch err
    printf('  WARNING: could not render %s (%s)\n',filename,err.message);
end
end


% ======================================================================
function figure_handle=new_offscreen_figure()
% Creates an invisible figure that can actually be printed to a file.
% Octave's default fltk toolkit refuses to render an invisible figure when
% there is no display, so the gnuplot toolkit is selected per figure (it has
% to be set on the handle -- setting it as a default is ignored here).
figure_handle=figure('visible','off');
if exist('OCTAVE_VERSION','builtin')
    try
        graphics_toolkit(figure_handle,'gnuplot');
    catch
        % leave the default toolkit in place and let print try anyway
    end
end
end


% ======================================================================
function make_time_plot(results,labels,qp_values,filename)
markers={'-o','-s','-^','-d'};
try
    figure_handle=new_offscreen_figure();
    hold on;
    for r=1:numel(results)
        plot(qp_values,results{r}.enc_time,markers{mod(r-1,numel(markers))+1},'LineWidth',1.6,'MarkerSize',6);
    end
    grid on;
    xlabel('Quantization parameter QP');
    ylabel('Encoding time (s), 5 CIF frames');
    title('Encoder run time by motion estimation strategy');
    legend(labels,'Location','NorthEast');
    print(filename,'-dpng','-r120');
    close(figure_handle);
    printf('  wrote %s\n',filename);
catch err
    printf('  WARNING: could not render %s (%s)\n',filename,err.message);
end
end


% ======================================================================
function make_visuals(sequence,figure_dir)
% Visual comparisons are written straight out with imwrite rather than being
% rendered through a figure: the result is pixel exact (important when the
% whole point is to show block artifacts) and needs no graphics toolkit.
width=352; height=288; number_of_frames=5; transform_blocksize=8;
me_blocksize=16; me_searchrange=8;
best_options=struct('me_strategy','subpel','rdo',true,'deblock',true);

original=yuv_read_one_frame(sequence,3,width,height);

% ---- original vs reconstruction at a fine and a coarse quantizer ----
for qp=[10 30]
    coded_file=[tempname() '.mat'];
    recon_file=[tempname() '.yuv'];
    encoder_opt(sequence,coded_file,width,height,number_of_frames,transform_blocksize, ...
                qp,me_blocksize,me_searchrange,best_options);
    decoder_opt(coded_file,recon_file);
    reconstructed=yuv_read_one_frame(recon_file,3,width,height);

    write_side_by_side(original,reconstructed, ...
        fullfile(figure_dir,sprintf('reconstruction_qp%d.png',qp)));
    printf('  reconstruction QP=%d frame 3: %.2f dB\n',qp,psnr_of_frame(original,reconstructed));

    delete(coded_file); delete(recon_file);
end

% ---- deblocking filter, on vs off, at a coarse quantizer ----
qp=30;
recon_without=[tempname() '.yuv'];  coded_a=[tempname() '.mat'];
recon_with=[tempname() '.yuv'];     coded_b=[tempname() '.mat'];
encoder_opt(sequence,coded_a,width,height,number_of_frames,transform_blocksize,qp,me_blocksize,me_searchrange, ...
            struct('me_strategy','full','deblock',false));
decoder_opt(coded_a,recon_without);
encoder_opt(sequence,coded_b,width,height,number_of_frames,transform_blocksize,qp,me_blocksize,me_searchrange, ...
            struct('me_strategy','full','deblock',true));
decoder_opt(coded_b,recon_with);

without_deblocking=yuv_read_one_frame(recon_without,3,width,height);
with_deblocking=yuv_read_one_frame(recon_with,3,width,height);
printf('  QP=30 frame 3: no deblocking %.2f dB, in-loop deblocking %.2f dB\n', ...
       psnr_of_frame(original,without_deblocking),psnr_of_frame(original,with_deblocking));

% zoom into a region, magnified, so the block edges are actually visible
rows=113:208; cols=113:208;
write_side_by_side(magnify(without_deblocking(rows,cols),3), ...
                   magnify(with_deblocking(rows,cols),3), ...
                   fullfile(figure_dir,'deblocking_comparison.png'));

delete(coded_a); delete(coded_b); delete(recon_without); delete(recon_with);

% ---- motion vector field ----
frame1=yuv_read_one_frame(sequence,1,width,height);
frame2=yuv_read_one_frame(sequence,2,width,height);
motion_vectors=blockbased_motion_search(frame2,frame1,me_blocksize,me_searchrange);
try
    figure_handle=new_offscreen_figure();
    plot_motion_vectors(height,width,me_blocksize,me_searchrange,motion_vectors);
    title('Motion vector field - flowergarden frame 2 (16x16 blocks, search range 8)');
    print(fullfile(figure_dir,'motion_vector_field.png'),'-dpng','-r120');
    close(figure_handle);
    printf('  wrote motion_vector_field.png\n');
catch err
    printf('  WARNING: could not render motion_vector_field.png (%s)\n',err.message);
end
end


% ======================================================================
function write_side_by_side(left_image,right_image,filename)
separator=ones(size(left_image,1),6);
montage=[left_image, separator, right_image];
imwrite(uint8(round(max(min(montage,1),0)*255)),filename);
printf('  wrote %s\n',filename);
end


% ======================================================================
function magnified=magnify(input_image,factor)
magnified=kron(input_image,ones(factor));
end
