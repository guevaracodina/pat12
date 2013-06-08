function out = pat_scrubbing_run(job)
% Performs scrubbing, defined as the process of creating a temporal mask, which
% specifies frames to ignore when performing calculations upon the data
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

firstPass = true;
%Big loop over scans
for scanIdx = 1:length(job.PATmat)
    try
        eTime = tic;
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        if ~isfield(PAT.jobsdone, 'GLMOK') % GLM OK
            fprintf('No GLM regression available for %s. Scan %d of %d ... skipping scrubbing\n',scanName, scanIdx, length(job.PATmat));
        else
            if ~isfield(PAT.jobsdone,'scrubOK') || job.force_redo
                % Get colors to include information
                IC = job.IC;
                colorNames = fieldnames(PAT.color);
                % Loop over available colors
                for c1 = 1:length(PAT.nifti_files)
                    doColor = pat_doColor(PAT,c1,IC);
                    if doColor
                        % skip B-mode only extract PA
                        if ~(PAT.color.eng(c1)==PAT.color.Bmode)
                            % First row CSV file
                            if firstPass,
                                save_data = fullfile(job.parent_results_dir{1},job.CSVfname);
                                fid = fopen(save_data, 'w');
                                fprintf(fid, 'Scan ID,Contrast,Scrub Flag,FD threshold(mm^-3),DVARS Threshold,Min. %%,Frames Kept,Total Frames,Scrub %%\n');
                                firstPass = false;
                            end
                            % Load motion parameters Q
                            Q = load (PAT.motion_parameters.fnameMAT);
                            Q = Q.Q;
                            % Compute Framewise displacement (FD)
                            FD = pat_compute_FD(Q, job.scrub_options.radius);
                            % Compute DVARS measure
                            DVARS = pat_compute_DVARS(PAT, c1);
                            % Masks creation (true(1) = reject frame)
                            FDmask{c1} = FD >= job.scrub_options.FDthreshold;
                            % DVARS threshold depends on color(contrast)
                            DVARSmask{c1} = DVARS >= job.scrub_options.DVARSthreshold(c1);
                            
                            if job.generate_figures
                                % Create figure
                                h = figure; set(h,'color','w'); colormap(job.figCmap); 
                                subplot(421)
                                plot(FD,'k-'); hold on
                                plot([1 numel(FD)], [job.scrub_options.FDthreshold job.scrub_options.FDthreshold], 'r:')
                                axis tight;  ylabel(sprintf('FD (%s)',colorNames{c1+1}))
                                figure(h); subplot(422)
                                plot(DVARS,'k-')
                                hold on
                                plot([1 numel(DVARS)], [job.scrub_options.DVARSthreshold(c1) job.scrub_options.DVARSthreshold(c1)], 'r:')
                                axis tight; ylabel(sprintf('DVARS (%s)',colorNames{c1+1}))
                                figure(h); subplot(423)
                                imagesc(FDmask{c1}',[0 1]); axis tight
                                set(gca,'YTick',[]); ylabel('FD mask')
                                figure(h); subplot(424)
                                imagesc(DVARSmask{c1}',[0 1]); axis tight
                                set(gca,'YTick',[]); ylabel('DVARS mask')
                            end
                            
                            % Augmented temporal mask by also marking the frames 1 back and 2 forward from any marked frames
                            % Find indices
                            idxL = find(FDmask{c1}(2:end));
                            idxR = find(FDmask{c1}(1:end-1));
                            % Augment FD mask
                            newIdxL = local_augment_mask(idxL, job.scrub_options.frameAugmBack, 'l');
                            newIdxR = local_augment_mask(idxR, job.scrub_options.frameAugmFwd, 'r');
                            FDmask{c1}([newIdxL; newIdxR]) = true;
                            
                            % Find indices
                            idxL = find(DVARSmask{c1}(2:end));
                            idxR = find(DVARSmask{c1}(1:end-1));
                            % Augment DVARS mask
                            newIdxL = local_augment_mask(idxL, job.scrub_options.frameAugmBack, 'l');
                            newIdxR = local_augment_mask(idxR, job.scrub_options.frameAugmFwd, 'r');
                            DVARSmask{c1}([newIdxL; newIdxR]) = true;
                            % Create temporal masking, conservatively choosing the intersection (AND) of the
                            % two temporal masks to generate a final temporal mask
                            if job.scrub_options.intersection
                                % intersection (AND)
                                scrubMask{c1} = FDmask{c1} & DVARSmask{c1};
                            else
                                % disjunction (OR)
                                scrubMask{c1} = FDmask{c1} | DVARSmask{c1};
                            end
                            
                            frames2keep(c1) = numel(find(~scrubMask{c1}));
                            totalFrames(c1) = numel(scrubMask{c1});
                            
                            scrubPercent(c1) = 100 *  frames2keep(c1) ./ totalFrames(c1);
                            if scrubPercent(c1) >= job.scrub_options.percentKeep
                                scrubFlag(c1) = true;
                            else
                                scrubFlag(c1) = false;
                            end
                            
                            if job.generate_figures
                                figure(h); subplot(425)
                                imagesc(FDmask{c1}',[0 1]); axis tight
                                set(gca,'YTick',[]); ylabel('FD augmented')
                                figure(h); subplot(426)
                                imagesc(DVARSmask{c1}',[0 1]); axis tight
                                set(gca,'YTick',[]); ylabel('DVARS augmented')
                                figure(h); subplot(414); 
                                imagesc(scrubMask{c1}',[0 1]); axis tight
                                set(gca,'YTick',[]); xlabel('Frames');
                                ylabel('Temporal mask')
                                % Save figures
                                pat_save_figs(job, h, 'scrub', scanIdx, c1, 0, 'Scrub');
                            end
                            
                            % Negation just to make indexing more natural in
                            % later stages of the fcPAT pipeline, i.e. we'll
                            % keep those frames marked as true.
                            scrubMask{c1} = ~scrubMask{c1};
                            % CSV file
                            fprintf(fid,'%s,%s,%i,%.4f,%.2f,%.2f,%d,%d,%.2f\n',scanName,colorNames{c1+1},int8(scrubFlag(c1)),1e3*job.scrub_options.FDthreshold,job.scrub_options.DVARSthreshold(c1),job.scrub_options.percentKeep,frames2keep(c1),totalFrames(c1),scrubPercent(c1));
                        end % Except B-mode
                    end % do color
                end % colors loop
                PAT.motion_parameters.scrub(1).fname = fullfile(dir_patmat,'scrubbing.mat');
                PAT.motion_parameters.scrub(1).CSVfname = save_data;
                save(fullfile(dir_patmat,'scrubbing.mat'), 'scrubFlag', 'scrubPercent',...
                    'frames2keep', 'totalFrames', 'scrubMask', 'DVARSmask', 'FDmask');
                % correlation succesful!
                PAT.jobsdone.scrubOK = true;
                % Save PAT matrix
                save(PATmat,'PAT');
            end % scrubbing OK or redo job
        end % GLM OK
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc(eTime)),'HH:MM:SS')]);
        fprintf('Scan %s, %d of %d complete %30s\n', scanName, scanIdx, length(job.PATmat), spm('time'));
        out.PATmat{scanIdx} = PATmat;
    catch exception
        out.PATmat{scanIdx} = PATmat;
        fclose all;
        disp(exception.identifier)
        disp(exception.stack(1))
    end
end % loop over scans
% close .CSV file
fclose(fid);
end % pat_scrubbing_run

function newIdx = local_augment_mask(idx, frames2augment, LR)
newIdx = [];
switch lower(LR)
    case 'l'
        augmIdx = idx - frames2augment;
        for iFrames = 1:numel(idx),
            newIdx = [newIdx; (augmIdx(iFrames):idx(iFrames))'];
        end
    case 'r'
        augmIdx = idx + frames2augment;
        for iFrames = 1:numel(idx),
            newIdx = [newIdx; (idx(iFrames):augmIdx(iFrames))'];
        end
    otherwise
        newIdx = [];
end
end
