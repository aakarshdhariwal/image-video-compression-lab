function summarize_results(output_root)
% summarize_results(output_root)
%
% Reads the .mat files produced by run_all_benchmarks and prints the summary
% tables quoted in the README, including Bjontegaard-Delta rate figures
% (negative BD-rate = fewer bits for the same quality = better).

if nargin<1 || isempty(output_root); output_root='..'; end
data_dir=fullfile(output_root,'results','data');

% ---------------- intra vs hybrid ----------------
f=fullfile(data_dir,'dr_intra_vs_hybrid.mat');
if exist(f,'file')
    load(f);
    printf('\n================ INTRA-ONLY vs HYBRID (flowergarden) ================\n');
    print_curve('Intra only',intra);
    print_curve('Hybrid (full search)',hybrid);
    [r,q]=bd_rate(intra.rate_kbps,intra.psnr,hybrid.rate_kbps,hybrid.psnr);
    printf('  BD-rate (PSNR): %+7.2f %%   BD-PSNR: %+6.3f dB\n',r,q);
    [r,q]=bd_rate(intra.rate_kbps,intra.ssim,hybrid.rate_kbps,hybrid.ssim);
    printf('  BD-rate (SSIM): %+7.2f %%   BD-SSIM: %+6.4f\n',r,q);
end

% ---------------- motion estimation strategies ----------------
f=fullfile(data_dir,'me_strategies.mat');
if exist(f,'file')
    load(f);
    printf('\n================ MOTION ESTIMATION STRATEGIES ================\n');
    for k=1:numel(me_results)
        print_curve(labels{k},me_results{k});
    end
    printf('  relative to full search:\n');
    for k=2:numel(me_results)
        [r,q]=bd_rate(me_results{1}.rate_kbps,me_results{1}.psnr, ...
                      me_results{k}.rate_kbps,me_results{k}.psnr);
        speedup=mean(me_results{1}.enc_time)/mean(me_results{k}.enc_time);
        printf('    %-22s BD-rate %+7.2f %%  BD-PSNR %+6.3f dB  encode speedup x%.2f\n', ...
               labels{k},r,q,speedup);
    end
end

% ---------------- extension ablation ----------------
f=fullfile(data_dir,'ablation.mat');
if exist(f,'file')
    load(f);
    printf('\n================ EXTENSION ABLATION (flowergarden) ================\n');
    for k=1:numel(ablation)
        print_curve(labels{k},ablation{k});
    end
    printf('  relative to the baseline codec:\n');
    for k=2:numel(ablation)
        [r,q]=bd_rate(ablation{1}.rate_kbps,ablation{1}.psnr, ...
                      ablation{k}.rate_kbps,ablation{k}.psnr);
        [rs,qs]=bd_rate(ablation{1}.rate_kbps,ablation{1}.ssim, ...
                        ablation{k}.rate_kbps,ablation{k}.ssim);
        printf('    %-26s BD-rate %+7.2f %%  BD-PSNR %+6.3f dB  |  BD-rate(SSIM) %+7.2f %%  BD-SSIM %+7.4f\n', ...
               labels{k},r,q,rs,qs);
    end
end

% ---------------- all sequences ----------------
f=fullfile(data_dir,'sequences.mat');
if exist(f,'file')
    load(f);
    printf('\n================ ALL TEST SEQUENCES (fully extended codec) ================\n');
    for k=1:numel(sequence_results)
        print_curve(strrep(all_sequences{k},'_short_cif.yuv',''),sequence_results{k});
    end
end

% ---------------- JPEG baseline ----------------
f=fullfile(data_dir,'jpeg_baseline.mat');
if exist(f,'file')
    load(f);
    printf('\n================ EXTERNAL JPEG BASELINE (flowergarden) ================\n');
    print_curve('JPEG per frame',jpeg);
    print_curve('This codec, intra only',ours_intra);
    print_curve('This codec, fully extended',ours);
    [r,q]=bd_rate(jpeg.rate_kbps,jpeg.psnr,ours_intra.rate_kbps,ours_intra.psnr);
    printf('  intra codec vs JPEG     : BD-rate %+7.2f %%  BD-PSNR %+6.3f dB\n',r,q);
    [r,q]=bd_rate(jpeg.rate_kbps,jpeg.psnr,ours.rate_kbps,ours.psnr);
    printf('  extended codec vs JPEG  : BD-rate %+7.2f %%  BD-PSNR %+6.3f dB\n',r,q);
end

printf('\n');
end


function print_curve(name,result)
printf('\n  %s\n',name);
printf('    %-6s %10s %8s %8s %9s\n','QP','kbit/s','PSNR','SSIM','enc (s)');
for k=1:numel(result.rate_kbps)
    printf('    %-6d %10.1f %8.2f %8.4f %9.1f\n', ...
           result.qp(k),result.rate_kbps(k),result.psnr(k),result.ssim(k),result.enc_time(k));
end
end
