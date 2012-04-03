function out = pat_simu_montecarlo_run(job)
% Entree: Longueur onde min, max, step
% Volume, dims

%Code
% Appel mua = prahl
% Appel musp = loi puissance (a lambda^-b)
% Simule 1 transducteur
% Sortie
% Sauve psf_longueur_onde, mua, musp, dimensions, resolutionspatiale
% Figure de la configuration

% PSF Monte Carlo. (MCX.exe)

% Loop over acquisitions
PATmat = job.PATmat;
for scanIdx = 1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        
        % Charger le volume de simulation segmenté
        load(job.seg_volume{1});
        
        % Calcul du nombre de voxels
        PAT.MonteCarlo.dims = job.dims;
        PAT.MonteCarlo.vox_size = job.vox_size;
        PAT.MonteCarlo.anisotropy = job.anisotropy;
        if (PAT.MonteCarlo.vox_size < 1.0)
            param.dx = PAT.MonteCarlo.vox_size;
            vox_scale_factor = 1/PAT.MonteCarlo.vox_size;
        else
            % Dimension des voxels (en mm)
            param.dx = PAT.MonteCarlo.vox_size;
            vox_scale_factor = 1;   
        end
        
        % Verifie que les tailles correspondent
        n_vox_x = PAT.MonteCarlo.dims(1)*vox_scale_factor;
        n_vox_y = PAT.MonteCarlo.dims(2)*vox_scale_factor;
        n_vox_z = PAT.MonteCarlo.dims(3)*vox_scale_factor; 
        size_seg_volume = size(segmented_volume); 
        
        if (size_seg_volume(1) ~= n_vox_x || size_seg_volume(2) ~= n_vox_y || size_seg_volume(3) ~= n_vox_z)
            ME = MException('pat_kwave_run:badSize', ...
             'Segmented volume does not correspond to size entered.'); 
            throw ME;
        end
        
        % Parametre du modele pour le coefficient d'absorption
        PAT.MonteCarlo.scat_params = job.scat_params;
        % Longueurs d'onde 
        PAT.MonteCarlo.wavelengths = job.wavelengths;
        % Nombre de voxels dans le volume en x,y,z
%         param.dim_psf = [floor(PAT.MonteCarlo.dims(1)/param.dx)+2 floor(PAT.MonteCarlo.dims(2)/param.dx)+2 floor(PAT.MonteCarlo.dims(3)/param.dx)+2];
        param.dim_psf = [floor(PAT.MonteCarlo.dims(1)/param.dx) floor(PAT.MonteCarlo.dims(2)/param.dx) floor(PAT.MonteCarlo.dims(3)/param.dx)];
        
        % Rayon de la source (en mm)
        param.rad = 0.8*vox_scale_factor;      

%         make_geom_uniform_GPU(param.dim_psf(1),param.dim_psf(2),param.dim_psf(3));
        make_geom_GPU(segmented_volume);

        % Matrice des sources
        central_pos = [ param.dim_psf(1)/2 param.dim_psf(2)/2 0.01;];
        matrix_src_pos = zeros(24,3);
        matrix_src_pos_x = zeros(12,1);
        matrix_src_pos_x(:) = -11:2:11;
        matrix_src_pos_x = matrix_src_pos_x.*vox_scale_factor;
        
        % Definition du transducteur 20Mhz
        for i = 1:12
            matrix_src_pos(i,1) = matrix_src_pos_x(i) + central_pos(1);
            matrix_src_pos(i+12,1) = matrix_src_pos_x(i) + central_pos(1);
            matrix_src_pos(i,2) = central_pos(2) + 3*vox_scale_factor;
            matrix_src_pos(i+12,2) = central_pos(2) - 3*vox_scale_factor;
        end
        
        matrix_src_pos(:,3) = 0.01;
        
        
        % %% Validation des positions
        %
%         test = zeros(100,100);
%         figure; plot(matrix_src_pos(:,1),matrix_src_pos(:,2),'o');
%         axis equal;
%         xlabel('mm')
%         ylabel('mm')
        
        
        %% Matrice de direction
        % Code ne roule pas lorsque vecteur direction unitaire
        
        matrix_dir = zeros(24,3);
        matrix_dir(1:12,2) = -3;
        matrix_dir(13:24,2) = 3;
        matrix_dir(:,3) =  5;
        
        % Spectre du sang (région par défaut)    
        [ext_hbo ext_hbr] = pat_get_extinctions(PAT.MonteCarlo.wavelengths);
        
        for i_wav = 1:length(PAT.MonteCarlo.wavelengths)
            
            % Hypothese (devrait etre une entree)
            blood_volume = 100e-6; % 100 uM
            saturation = 0.8; % En pourcent
            hbo = saturation*blood_volume;
            hbr = (1-saturation)*blood_volume;
            param.mua = ext_hbo(i_wav)*hbo + ext_hbr(i_wav)*hbr;
            
            % Pour le scatter a venir
            param.musp = PAT.MonteCarlo.scat_params(2) * (PAT.MonteCarlo.wavelengths(i_wav)/PAT.MonteCarlo.scat_params(1))^(-PAT.MonteCarlo.scat_params(3));
            param.mus = param.musp/(1-PAT.MonteCarlo.anisotropy);
            
            
            % Simulation Monte-Carlo
            psf_mcx = zeros(param.dim_psf(1),param.dim_psf(2),param.dim_psf(3));
            
            
            % Correction si vox size < 1 mm
            param.musp = param.musp / vox_scale_factor;
            param.mus = param.mus / vox_scale_factor;
            param.mua = param.mua / vox_scale_factor;
            param.g = PAT.MonteCarlo.anisotropy;
            
            % Conversion des cm-1 en mm-1
            param.musp = param.musp * 0.1;
            param.mus = param.mus * 0.1;
            param.mua = param.mua * 0.1;            
            
            % Vox size pour mcx doit etre 1mm
            vox_size_for_mcx = 1;
            
            for iSource = 1:24
                
                src_pos = matrix_src_pos(iSource,:);                
                det_pos = src_pos;
                dir = matrix_dir(iSource,:);
                
                % Creation du fichier de simulation `src.cfg` qui est utilise pour la
                % simulation monte-carlo
                
                make_simucfg_GPU(src_pos,det_pos,dir,param.rad,vox_size_for_mcx,...
                    param.dim_psf(1),param.dim_psf(2),param.dim_psf(3),param.mua, param.mus, param.g);
                
                % Nous pouvons maintenant faire la simulation monte-carlo... plus long,
                % c'est pourquoi cette première partie est dans une cell séparée, elle
                % n'aura pas à être re-exécutée
                res = system('mcx.exe  -t 32768 -T 64 -g 10 -n 1e7 -f qtest.inp -s qtest -r 100 -a 0 -b 0')
                
                %-t 32768   total thread number
                %-T 64      thread number per block
                %-g 10      number of time gates per run
                %-n 1e7     total photon number
                %-f qtest.inp    read config from a file
                %-s qtest         label for output file names
                %-r 100     number of repetitions
                %-a 0       Matlab array
                %-b 0     photons to exit at boundary
                
                % Lecture de cette simulation et nettoyage des gros fichiers
                psf_mcx = psf_mcx + loadmc2('qtest.mc2',param.dim_psf);
            end
            % Sauvegarde de la psf d'une source dans un fchier matlab
            save(fullfile(PAT.output_dir, ['psf_MCX_', num2str(PAT.MonteCarlo.wavelengths(i_wav)),'_nm.mat']),'psf_mcx')
        end
        PAT.MonteCarlo.psf=fullfile(PAT.output_dir, 'psf_MCX_');
        PAT.jobsdone.simu_montecarlo = 1;
        save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
        out.PATmat{scanIdx} = PATmat{scanIdx};
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end

end
