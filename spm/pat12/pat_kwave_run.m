function out = pat_kwave_run(job)
% Entree: Path du volume segmente et PAT.mat


%Code



% Loop over acquisitions
PATmat=job.PATmat;
for scanIdx=1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        
        % Charger le volume de simulation segmenté
        load(job.seg_volume{1});

        % Verifie si un MC a ete fait
        % (a faire)
            
        % Verifie que les tailles correspondent
        size_seg_volume = size(segmented_volume);    
        if (size_seg_volume(1) ~= PAT.MonteCarlo.dims(1) || size_seg_volume(2) ~= PAT.MonteCarlo.dims(2) || size_seg_volume(3) ~= PAT.MonteCarlo.dims(3))
            ME = MException('pat_kwave_run:badSize', ...
             'Segmented volume does not correspond to size entered.'); 
            throw ME;
        end
        
        % Trouver le nombre de régions segmentées
        n_regions = max(segmented_volume(:));
        
        % Spectres relatifs des inclusions
        pat_spectrums = pat_get_spectrums(PAT.MonteCarlo.wavelengths, 1:n_regions);
        
        % Aborption volume
        absorption_volume = ones(size(segmented_volume));
        
        
        for i_wav = 1:length(PAT.MonteCarlo.wavelengths)
             
            load(fullfile(PAT.output_dir, ['psf_MCX_', num2str(PAT.MonteCarlo.wavelengths(i_wav)),'_nm.mat']),'psf_mcx')
            
            psf_mcx = psf_mcx(2:end-1, 2:end-1, 2:end-1);
            for i_regions = 1:n_regions
                indices_region = find(segmented_volume == i_regions);
                absorption_volume(indices_region) = pat_spectrums(i_wav, i_regions);
            end
            
            PAT_source = absorption_volume .* psf_mcx;
            
            % Sauvegarde de la source de signal PAT dans un fichier matlab
            save(fullfile(PAT.output_dir, ['PAT_source_', num2str(PAT.MonteCarlo.wavelengths(i_wav)),'_nm.mat']),'PAT_source')
             
        end
        

%         PAT.jobsdone.kwave = 1;
%         save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
         out.PATmat{scanIdx} = PATmat{scanIdx};
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end

end
