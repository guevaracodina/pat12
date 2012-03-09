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
PATmat=job.PATmat;
for scanIdx=1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        
        % Dimensions en mm (pour nous)
        PAT.MonteCarlo.dims=job.dims;
        PAT.MonteCarlo.vox_size=job.vox_size;
        % Dimension des voxels (en mm)
        param.dx = PAT.MonteCarlo.vox_size;
        % Parametre du modele pour le coefficient d'absorption
        PAT.MonteCarlo.scat_params = job.scat_params;

        % Nombre de voxels dans le volume en x,y,z
        param.dim_psf = [floor(PAT.MonteCarlo.dims(1)/param.dx)+2 floor(PAT.MonteCarlo.dims(2)/param.dx)+2 floor(PAT.MonteCarlo.dims(3)/param.dx)+2];
        
        % Rayon de la source (en mm)
        param.rad = 0.8;
        
        make_geom_GPU(param.dim_psf(1),param.dim_psf(2),param.dim_psf(3));
        
        
        % Matrice des sources
        central_pos = [ param.dx*param.dim_psf(1)/2 param.dx*param.dim_psf(2)/2 0.01;];
        matrix_src_pos = zeros(24,3);
        
        matrix_src_pos_x = zeros(12,1);
        matrix_src_pos_x(:) = -11:2:11;
        
        % Definition du transducteur 20Mhz
        for i = 1:12
            matrix_src_pos(i,1) = matrix_src_pos_x(i) + central_pos(1);
            matrix_src_pos(i+12,1) = matrix_src_pos_x(i) + central_pos(1);
            matrix_src_pos(i,2) = central_pos(2) + 3;
            matrix_src_pos(i+12,2) = central_pos(2) - 3;
        end
        
        matrix_src_pos(:,3) = 0.01;
        
        
        % %% Validation des positions
        %
        % test = zeros(50,50);
        % figure; plot(matrix_src_pos(:,1),matrix_src_pos(:,2),'o');
        % axis equal;
        % xlabel('mm')
        % ylabel('mm')
        
        
        %% Matrice de direction
        % Code ne roule pas lorsque vecteur direction unitaire
        
        matrix_dir = zeros(24,3);
        matrix_dir(1:12,2) = -3;
        matrix_dir(13:24,2) = 3;
        matrix_dir(:,3) =  11;
        
        % A deriver des lois
        
        % Pour l'absorption
        PAT.MonteCarlo.wavelengths=job.wavelengths;
        [ext_hbo ext_hbr] = pat_get_extinctions(PAT.MonteCarlo.wavelengths);
        
        for i_wav=1:length(PAT.MonteCarlo.wavelengths)
            % Hypothese (devrait etre une entree)
            blood_volume = 100e-6; % 100 uM
            saturation = 0.8; % En pourcent
            hbo=saturation*blood_volume;
            hbr=(1-saturation)*blood_volume;
            param.mua=ext_hbo(i_wav)*hbo+ext_hbr(i_wav)*hbr;
            
            % Pour le scatter a venir
            param.musp = PAT.MonteCarlo.scat_params(1) * (PAT.MonteCarlo.wavelengths(i_wav)/750)^(-PAT.MonteCarlo.scat_params(2));
            param.mus = param.musp;
            
            % Simulation Monte-Carlo
            psf_mcx=zeros(param.dim_psf(1),param.dim_psf(2),param.dim_psf(3));
            for iSource = 1:24
                
                src_pos = matrix_src_pos(iSource,:);
                det_pos = src_pos;%src_pos+[1.0 1.0 0.0 ];
                dir = matrix_dir(iSource,:);
                
                % Creation du fichier de simulation `src.cfg` qui est utilise pour la
                % simulation monte-carlo
                make_simucfg_GPU(src_pos,det_pos,dir,param.rad,param.dx,...
                    param.dim_psf(1),param.dim_psf(2),param.dim_psf(3),param.mua, param.mus);
                
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
