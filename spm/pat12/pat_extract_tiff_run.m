function out = pat_extract_tiff_run(job)
%_______________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%______________________________________________________________________
try
    for scanIdx=1:length(job.input_dir)
        
        % Set save structure and associated directory
        clear PAT
        PAT.input_dir=job.input_dir{scanIdx}
        filesdir=job.input_dir{scanIdx};
        files=dir(fullfile(filesdir,'*.tif'));
        
        dirlen=size(job.input_data_topdir{1},2);
        [pathstr, temp]=fileparts(filesdir);
        PAT.output_dir=fullfile(job.output_dir{1},pathstr(dirlen+1:end));
        if ~exist(PAT.output_dir,'dir'),mkdir(PAT.output_dir); end
        PATmat = fullfile(PAT.output_dir,'PAT.mat');
        tif_stack=fullfile(PAT.output_dir,'stack.tif');
        PAT.tif_stack=tif_stack;
        
        
        tmp_img=imread(fullfile(filesdir,files(1).name));
        
        % Get red channel and select area of interest for future analysis
        tmp_img=squeeze(tmp_img(:,:,1));
        hh=figure;
        imagesc(tmp_img);
        h=imrect;
        wait(h);
        pos = getPosition(h);
        range_x=round(pos(2)):round(pos(2)+pos(4));
        range_y=round(pos(1)):round(pos(1)+pos(3));
        close(hh);

        tmp_img=tmp_img(range_x,range_y,1);
        imwrite(tmp_img, tif_stack);

        for i=2:length(files)
            tmp_img=imread(fullfile(filesdir,files(i).name));
            tmp_img=squeeze(tmp_img(range_x,range_y,1));
            imwrite(tmp_img, tif_stack, 'WriteMode', 'append');
        end        
        PAT.jobsdone.extract_tiff=1;          
        save(PATmat,'PAT');
        out.PATmat{scanIdx} = PATmat;
     end

catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    out.PATmat{scanIdx} = PATmat;
end


