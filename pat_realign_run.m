function out = pat_realign_run(job)
%_______________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%______________________________________________________________________

%
% Frederic Lesage
% Email: frederic.lesage@polymtl.ca
%
PATmat=job.PATmat;
% Loop over acquisitions

% Create SPM figure window
spm_figure('Create','Interactive')
flags.fwhm=job.fwhm;
flags.rtm=job.rtm;
flags.sep=job.sep;
flags.quality=job.quality;

for scanIdx=1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        for iFile=1:length(PAT.nifti_files)
            P=pat_realign(PAT.nifti_files{iFile},flags);
            pat_reslice(P);
       end
        PAT.jobsdone.realign = 1;
        save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
        out.PATmat{scanIdx} = PATmat{scanIdx};
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end

end

