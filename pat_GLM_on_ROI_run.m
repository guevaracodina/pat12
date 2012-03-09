function out = pat_GLM_on_ROI_run(job)

PATmat=job.PATmat;
% Loop over acquisitions

for scanIdx=1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        
        % Creating nifti files to be able to use SPM later
        n_wav = tiff_frames(PAT.tif_stack);
        [pixw,pixh] = size(imread(PAT.tif_stack,1));
        [pathstr, name, ext] = fileparts(PAT.tif_stack);
        fname=fullfile(pathstr,[name,'.nii']);
        dim=[pixw,pixh,1];
        dt = [spm_type('float64') spm_platform('bigend')];
        pinfo=ones(3,1);
        mat=eye(4);
        for i_wav=1:n_wav
            hdr = pat_create_vol(fname, dim, dt, pinfo, mat, i_wav, imread(PAT.tif_stack,i_wav));
        end
        PAT.SPM.nifti_filename=fname;
        
        % Constructing inputs required for GLM analysis within the SPM
        % framework
        SPM.xY.VY=spm_vol(PAT.SPM.nifti_filename);
        % All regressors are identified here, lets take first 3 ICA
        % components just to test
        SPM.xX.name=cellstr(['ICA1';'ICA2';'ICA3']);
        SPM.xX.X=PAT.ICA.sig(1:3,:)'; % regression is along first dimension
        % A revoir
        SPM.xX.iB=[];
        SPM.xX.iG=[];
        SPM.xVi.Vi = {speye(size(SPM.xX.X,1))}; % Time correlation
        % GLM is performed here
        SPM = spm_spm(SPM);
        
        spmmat_file=fullfile(pathstr,'SPM.mat');
        PAT.SPM.spmmat_file=spmmat_file;
        save(PAT.SPM.spmmat_file,'SPM');
        
        
        %spm_conman(SPM)
        
        % Creer les contrastes et faire les stats (module separe?)
        % spm get spm xcon
        
        out.PATmat{scanIdx} = PATmat;
        
    catch exception
        out.PATmat{scanIdx} = PATmat;
        disp(exception.identifier)
        disp(exception.stack(1))
    end
end
end

%spm get spm

