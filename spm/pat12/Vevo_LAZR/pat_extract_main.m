function [PAT ROI] = pat_extract_main(PAT,ROI,job,d,d3,d4,c1,s1,colorOK,mask,Amask)
% The time course is made up of the means of all the pixel values in the
% ROI/seed.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

[all_ROIs selected_ROIs] = pat_get_rois(job);
msg_ColorNotOK = true;
nROI = 1:length(PAT.res.ROI); % All the ROIs
if isfield(job,'extractingBrainMask')
    if job.extractingBrainMask
        nROI = 1; % Only 1 brain mask
    end
end
% If activation mask is chosen
if ~isempty(Amask)
    Amask = pat_imresize(Amask, size(mask{nROI(1)}));
    for r1 = nROI
        mask{r1} = logical(mask{r1} .* Amask);
    end
end
% Loop over ROIs/seeds
for r1 = nROI,
    if all_ROIs || sum(r1==selected_ROIs)
        tmp_mask_done = false;
        for i3=1:d3
            for i4=1:d4
                %extracted data
                try tmp_d = d(:,:,i3,i4); end
                %just take mean over mask for now
                try
                    e = mean(tmp_d(mask{r1}));
                catch
                    if msg_ColorNotOK
                        msg = ['Problem extracting for color ' int2str(c1) ', session ' int2str(s1) ...
                            ',region ' int2str(r1) ': size mask= ' int2str(size(mask{r1},1)) 'x' ...
                            int2str(size(mask{r1},2)) ', but size image= ' int2str(size(tmp_d,1)) 'x' ...
                            int2str(size(tmp_d,2))];
                        PAT = pat_disp_msg(PAT,msg);
                        msg_ColorNotOK = false;
                    end
                    if colorOK
                        try
                            %try to resize mask - but only attempt to do it once
                            if ~tmp_mask_done
                                % tmp_mask = imresize(mask{r1},size(tmp_d));
                                % pat_imresize works with no image
                                % processing toolbox //EGC
                                tmp_mask = pat_imresize(mask{r1},size(tmp_d));
                                tmp_mask_done = true;
                            end
                            e = mean(tmp_d(tmp_mask));
                        catch
                            msg = ['Unable to extract color ' int2str(c1) ', session ' int2str(s1)];
                            PAT = pat_disp_msg(PAT,msg);
                            colorOK = false;
                        end
                    end
                end
                if colorOK
                    ROI{r1}{s1,c1} = [ROI{r1}{s1,c1} e];
                end
            end % Loop along 4th dimension
        end % Loop along 3rd dimension
    end
end % Loop over ROIs/seeds

% EOF

