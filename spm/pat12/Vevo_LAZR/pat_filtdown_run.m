function out = pat_filtdown_run(job)
% Band-pass filters (usually [0.009 - 0.8]Hz) the time series of an ROI (seed)
% and the global brain signal. Option to filter whole image time-series.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% out.PATmat = job.PATmat;
% return
% ------------------------------------------------------------------------------

for scanIdx = 1:length(job.PATmat)
    try
        tic
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        if ~isfield(PAT.jobsdone,'filtNdownOK') || job.force_redo
            % Get sampling period in seconds
            PAT.fcPAT.filtNdown(1).TR = pat_get_TR(PAT);
            % Original Sampling Frequency
            fs = 1/PAT.fcPAT.filtNdown.TR;
            % Filter order
            filterOrder = job.bpf.bpf_On.bpf_order;
            % Band-pass cut-off frequencies
            BPFfreq = job.bpf.bpf_On.bpf_freq;
            % Filter type
            fType = job.bpf.bpf_On.bpf_type;
            % Passband/Stopband ripple in dB
            Rp_Rs = [job.bpf.bpf_On.bpf_Rp job.bpf.bpf_On.bpf_Rs];
            
            % Retrieve data
            if isfield(PAT.jobsdone, 'seriesOK')
                ROIdata = load(PAT.ROI.ROIfname);
                ROIdata = ROIdata.ROI;
            end
            if isfield(PAT.jobsdone,'maskSeriesOK')
                brainMaskData = load(PAT.fcPAT.mask.fnameSeries);
                brainMaskData = brainMaskData.brainMaskSeries;
            end
            
            % Include colors
            IC = job.IC;
            % Band-pass filter configuration
            [z, p, k] = pat_temporalBPFconfig(fType, fs, BPFfreq, filterOrder, Rp_Rs);
            % Loop over sessions (in PAT only 1 session per scan)
            s1 = 1;
            
            colorNames = fieldnames(PAT.color);
            % Loop over available colors
            for c1 = 1:length(PAT.nifti_files)
                doColor = pat_doColor(PAT,c1,IC);
                if doColor
                    colorOK = true;
                    % skip B-mode only extract PA
                    if ~(PAT.color.eng(c1)==PAT.color.Bmode)
                        if job.wholeImage
                            %% Filtering whole image time series (y)
                            volY = spm_vol(PAT.nifti_files{1,c1});
                            y = spm_read_vols(volY);
                            % Preallocating output images
                            filtY = zeros(size(y));
                            % Computing lenght of time vector
                            % Read brain mask file
                            [PAT brainMask] = pat_get_brain_mask(PAT);
                            % brain mask was needed as a cell in pat_extract_main
                            brainMask = brainMask{1};
                            % Test if there was shrinkage
                            if size(brainMask,1)~= size(y,1)|| size(brainMask,2)~= size(y,2)
                                brainMask = pat_imresize(brainMask, [size(y,1) size(y,2)]);
                            end
                            % Color names
                            colorNames = fieldnames(PAT.color);
                            % Initialize progress bar
                            spm_progress_bar('Init', size(filtY,1), sprintf('Filtering color %d (%s)\n',c1,colorNames{1+c1}), 'Pixels along X');
                            pat_text_waitbar(0, sprintf('Filtering color %d (%s)',c1,colorNames{1+c1}))      % ascii progress bar
                            for iX = 1:size(filtY,1)
                                % Update progress bar
                                spm_progress_bar('Set', iX);
                                pat_text_waitbar(iX/size(filtY,1), sprintf('Processing pixel time course %d from %d', iX, size(filtY,1))); 
                                for iY = 1:size(filtY,2)
                                    if brainMask(iX,iY)
                                        % Only non-masked pixels are band-passs filtered
                                        filtY(iX,iY,1,:) = temporalBPFrun(squeeze(y(iX,iY,:)), z, p, k);
                                    end
                                end
                            end
                            spm_progress_bar('Clear');
                            pat_text_waitbar('Clear');
                            % Saving images
                            filtNdownfnameWholeImage = fullfile(dir_patmat,[scanName '_' PAT.color.eng(c1) '_filt_' sprintf('%05d',1) 'to' sprintf('%05d', size(filtY,4)) '.nii']);
                            % Create 4-D NIFTI file with filtered time trace of each pixel
                            pat_create_vol_4D(filtNdownfnameWholeImage, volY, filtY);
                            % filename saved in PAT structure
                            PAT.fcPAT.filtNdown.fnameWholeImage{s1, c1} = filtNdownfnameWholeImage;
                            fprintf('Filtering whole images for color %d (%s) completed %30s\n',c1,colorNames{1+c1},spm('time'))
                        end % End of filtering & downsampling whole images
                        if PAT.jobsdone.maskSeriesOK
                            %% Filtering global brain signal
                            % Retrieve time-course signal for brain mask
                            brainSignal = brainMaskData{1}{s1, c1};
                            % Band-passs filtering
                            brainSignal = temporalBPFrun(brainSignal, z, p, k);
                            % Update data cell
                            filtNdownBrain{1}{s1,c1} = brainSignal;
                        end
                        [all_ROIs selected_ROIs] = pat_get_rois(job);
                        nROI = 1:length(PAT.res.ROI); % All the ROIs
                        msg_ColorNotOK = true;
                        % Initialize output filtNdownROI
                        for r1 = nROI;
                            if all_ROIs || sum(r1==selected_ROIs)
                                filtNdownROI{r1}{s1,c1} = [];
                            end
                        end
                        % Loop over ROIs
                        for r1 = nROI; % All the ROIs
                            if all_ROIs || sum(r1==selected_ROIs)
                                try
                                    %% Filtering seeds
                                    % Retrieve time-series signal for given ROI and color
                                    ROIsignal = ROIdata{r1}{s1, c1};
                                    % Band-passs filtering
                                    ROIsignal = temporalBPFrun(ROIsignal, z, p, k);
                                    % Plot and print data if required
                                    subfunction_plot_filtNdown_data(job, PAT, dir_patmat, ROIdata, ROIsignal, r1, c1);
                                catch
                                    if msg_ColorNotOK
                                        msg = ['Problem filtering/downsampling for color ' int2str(c1) ', session ' int2str(s1) ...
                                            ',region ' int2str(r1) ': size ROIsignal= ' int2str(size(ROIsignal,1)) 'x' ...
                                            int2str(size(brainSignal,2)) ', but brainSignal= ' int2str(size(brainSignal,1)) 'x' ...
                                            int2str(size(brainSignal,2))];
                                        PAT = pat_disp_msg(PAT,msg);
                                        msg_ColorNotOK = false;
                                    end
                                    if colorOK
                                        try
                                            %% Filtering seeds
                                            % Retrieve time-series signal for given ROI and color
                                            ROIsignal = ROIdata{r1}{s1, c1};
                                            % Band-passs filtering
                                            ROIsignal = temporalBPFrun(ROIsignal, z, p, k);
                                            % Plot and print data if required
                                            subfunction_plot_filtNdown_data(job, PAT, dir_patmat, ROIdata, ROIsignal, r1, c1);
                                        catch
                                            msg = ['Unable to extract color ' int2str(c1) ', session ' int2str(s1)];
                                            PAT = pat_disp_msg(PAT,msg);
                                            colorOK = false;
                                        end
                                    end
                                end
                                if colorOK
                                    filtNdownROI{r1}{s1,c1} = ROIsignal;
                                    filtNdownBrain{1}{s1,c1} = brainSignal;
                                end
                            end
                        end % ROI loop
                        if colorOK
                            filtNdownROI{r1}{s1,c1} = ROIsignal;
                            filtNdownBrain{1}{s1,c1} = brainSignal;
                            fprintf('Filtering ROIs/seeds for color %d (%s) completed %30s\n',c1,colorNames{1+c1},spm('time'))
                        end
                    end
                end
            end % Colors loop
            
            % Filter and Downsampling succesful!
            PAT.jobsdone.filtNdownOK = true;
            % Save filtered & downsampled data
            filtNdownfname = fullfile(dir_patmat,'filtNdown.mat');
            save(filtNdownfname,'filtNdownROI','filtNdownBrain');
            % Update .mat file name in PAT structure
            PAT.fcPAT.filtNdown.fname = filtNdownfname;
            % Band-pass frequency
            PAT.fcPAT.filtNdown.BPFfreq = BPFfreq;
            % Band-pass filter order
            PAT.fcPAT.filtNdown.BPForder = filterOrder;
            % Band-pass filter type
            PAT.fcPAT.filtNdown.BPFtype = fType;
            save(PATmat,'PAT');
        end
        out.PATmat{scanIdx} = PATmat;
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        fprintf('Scan %s, %d of %d complete %30s\n', splitStr{end-1}, scanIdx, length(job.PATmat), spm('time'));
    catch exception
        out.PATmat{scanIdx} = job.PATmat{scanIdx};
        disp(exception.identifier)
        disp(exception.stack(1))
    end % End of try
end % End of main for
end % End of function


function subfunction_plot_filtNdown_data(job, PAT, dir_patmat, ROIdata, ROIsignal, r1, c1)
% Plots time course and spectrum for both the raw and filtered data
if job.generate_figures
    % ------------------------ Plot options ------------------------------------
    titleFontSize = 14;
    axisLabelFontSize = 14;
    axisFontSize = 12;
    lineWidth = 1.5;
    % --------------------------------------------------------------------------
    
    [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
	scanName = splitStr{end-1};
    % Only 1 session per scan in PAT
    s1 = 1;
    % Original Sampling Frequency (Hz)
    fs = 1/PAT.fcPAT.filtNdown.TR;
    % Get color names
    colorNames = fieldnames(PAT.color);
    % Band-pass cut-off frequencies
    BPFfreq = job.bpf.bpf_On.bpf_freq;
    
    % --------------------------- Plotting results -----------------------------
    % Display plots on SPM graphics window
    h = spm_figure('GetWin', 'Graphics');
    spm_figure('Clear', 'Graphics');
    % Positive FFT (raw signal)
    [X, freq] = pat_positiveFFT(ROIdata{r1}{s1, c1}, fs);
    % Time vector
    t = 0:1/fs:(1/fs)*(numel(ROIdata{r1}{s1, c1})-1);
    
    subplot(221)
    plot(t, ROIdata{r1}{s1, c1},'k-','LineWidth',lineWidth)
    title(sprintf('%s_R%02d(%s)_C%d(%s)\n',scanName,r1,PAT.ROI.ROIname{r1},c1,colorNames{1+c1}),'interpreter', 'none','FontSize',titleFontSize);
    xlabel('t [s]','FontSize',axisLabelFontSize)
    ylabel('[a.u.]','FontSize',axisLabelFontSize)
    set(gca,'FontSize',axisFontSize)
    axis tight
    
    subplot(222)
    semilogx(freq, abs(X),'k-','LineWidth',lineWidth);
    title(sprintf('Unfiltered spectrum'),'interpreter', 'none','FontSize',titleFontSize);
    xlabel('f [Hz]','FontSize',axisLabelFontSize)
    set(gca,'FontSize',axisFontSize)
    xlim([0 max(freq)]);
    % Plot filter band
    yLimits = get(gca,'Ylim');  hold on;
    plot([BPFfreq(1) BPFfreq(1)],[yLimits(1) yLimits(2)],'r--','LineWidth',lineWidth)
    plot([BPFfreq(2) BPFfreq(2)],[yLimits(1) yLimits(2)],'r--','LineWidth',lineWidth)
    
    subplot(223)
    % Positive FFT (filtered signal)
    [X, freq] = pat_positiveFFT(ROIsignal, fs);
    plot(t, ROIsignal,'k-','LineWidth',lineWidth)
    title(sprintf('Filtered time-course'),'interpreter', 'none','FontSize',titleFontSize);
    xlabel('t [s]','FontSize',axisLabelFontSize)
    ylabel('[a.u.]','FontSize',axisLabelFontSize)
    set(gca,'FontSize',axisFontSize)
    axis tight
    
    subplot(224)
    semilogx(freq, abs(X),'k-','LineWidth',lineWidth);
    title('Filtered spectrum','interpreter', 'none','FontSize',titleFontSize);
    xlabel('f [Hz]','FontSize',axisLabelFontSize)
    set(gca,'FontSize',axisFontSize)
    xlim([0 max(freq)]);
    % --------------------------------------------------------------------------
    
    % --------------------------- Saving plots ---------------------------------
    newName = [sprintf('%s_R%02d_C%d',scanName,r1,c1) '_filt'];
    if job.save_figures
        if isfield(job.PATmatCopyChoice,'PATmatCopy')
            dir_filtfig = fullfile(dir_patmat,strcat('fig_',job.PATmatCopyChoice.PATmatCopy.NewPATdir));
        else
            dir_filtfig = fullfile(dir_patmat,'fig_FiltNDown');
        end
        if ~exist(dir_filtfig,'dir'), mkdir(dir_filtfig); end
        % Save as PNG
        print(h, '-dpng', fullfile(dir_filtfig,newName), '-r300');
        % Save as a figure
        saveas(h, fullfile(dir_filtfig,newName), 'fig');
    end % Save figures
    % --------------------------------------------------------------------------
end % Generate figures
end % subfunction_plot_filtNdown_data


% EOF
