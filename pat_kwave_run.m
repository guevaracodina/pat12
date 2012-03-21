function out = pat_kwave_run(job)
% Entree: Path du volume segmenté et PAT.mat


% Loop over acquisitions
addpath('D:\Users\Carl\kwave');
PATmat = job.PATmat;
kwave_vox_size = job.kwave_vox_size;


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
        
        % Absorption volume
        absorption_volume = ones(size(segmented_volume));
        
        
        for i_wav = 1:length(PAT.MonteCarlo.wavelengths)
             
            load(fullfile(PAT.output_dir, ['psf_MCX_', num2str(PAT.MonteCarlo.wavelengths(i_wav)),'_nm.mat']),'psf_mcx')
            
            psf_mcx = psf_mcx(2:end-1, 2:end-1, 2:end-1);
            for i_regions = 1:n_regions
                indices_region = find(segmented_volume == i_regions);
                absorption_volume(indices_region) = pat_spectrums(i_wav, i_regions);
            end
            
            PAT_source = absorption_volume .* psf_mcx;
            PAT_source = PAT_source / 10^8;
            
            % Sauvegarde de la source de signal PAT dans un fichier matlab
            % Pour debugging
            save(fullfile(PAT.output_dir, ['PAT_source_', num2str(PAT.MonteCarlo.wavelengths(i_wav)),'_nm.mat']),'PAT_source')
                     
        
            % =========================================================================
            % KWAVE SIMULATION
            % =========================================================================
        
            x = PAT.MonteCarlo.dims(1)*0.001;   % size of the domain in the x direction [m]
            y = PAT.MonteCarlo.dims(2)*0.001; 
            z = PAT.MonteCarlo.dims(3)*0.001;   
        
            dx = kwave_vox_size*0.001; % grid point spacing in the x direction [m]
            dy = dx;
            dz = dx;
            
            Nx = floor(x/dx);
            Ny = floor(y/dy);
            Nz = floor(z/dz);

            % define the properties of the propagation medium
            % a deplacer dans línterface un jour
            medium.sound_speed = 1500;      % [m/s]
            
            % time array
            dt = 0.05e-6;                      % [s]
            t_end = 10e-6;                 % [s]
            
            % computation settings
            input_args = {'DataCast', 'single', 'PlotSim', false};
            
            % Create initial pressure distribution
            % Interpolation de la fluence de la source PAT sur la nouvelle
            % grille
            [X,Y,Z] = meshgrid(1:1:size(PAT_source,1), 1:1:size(PAT_source,2),1:1:size(PAT_source,3));
            
            XI_vec = linspace(1,size(PAT_source,1),Nx);
            YI_vec = linspace(1,size(PAT_source,2),Ny);
            ZI_vec = linspace(1,size(PAT_source,3),Nz);
            
            [XI,YI,ZI] = meshgrid(XI_vec, YI_vec, ZI_vec);
            
            source.p0 = interp3(X,Y,Z,PAT_source,XI,YI,ZI);
           
            % create the computational grid
            kgrid = makeGrid(Nx, dx, Ny, dy, Nz, dz);
            
            % create the time array
            kgrid.t_array = 0:dt:t_end;
            
            % define transducer points
            sensor.mask = zeros(Nx, Ny, Nz);
            sensor.mask(:,:,1) = 1;
            
            % run the simulation
            sensor_data_3D = kspaceFirstOrder3D(kgrid, medium, source, sensor, input_args{:});
         
            % Sauvegarde de la source de signal PAT dans un fichier matlab
            % Pour debugging
            save(fullfile(PAT.output_dir, ['sensor_data_', num2str(PAT.MonteCarlo.wavelengths(i_wav)),'_nm.mat']),'sensor_data_3D')
            
        end
        
        PAT.jobsdone.kwave = 1;
        %         save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
        out.PATmat{scanIdx} = PATmat{scanIdx};
        
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end
