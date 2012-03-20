function out = pat_kwave_run(job)
% Entree: Path du volume segmenté et PAT.mat


%Code



% Loop over acquisitions
PATmat=job.PATmat;
nvox = job.nvox;

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
            
            % Sauvegarde de la source de signal PAT dans un fichier matlab
            save(fullfile(PAT.output_dir, ['PAT_source_', num2str(PAT.MonteCarlo.wavelengths(i_wav)),'_nm.mat']),'PAT_source')
             
        end
        
        % =========================================================================
        % KWAVE
        % =========================================================================
        
        % =========================================================================
        % SETTINGS
        % =========================================================================

% size of the computational grid
Nx = nvox(1);  
Ny = nvox(2);  
Nz = nvox(3);  
x = PAT.MonteCarlo.dims(1);   % size of the domain in the x direction [m]
dx = x/Nx;  % grid point spacing in the x direction [m]
dy = dx;
dz = dx;

% define the properties of the propagation medium
medium.sound_speed = 1500;      % [m/s]

% % size of the initial pressure distribution
% source_radius = 2;              % [grid points]

% % distance between the centre of the source and the sensor
% source_sensor_distance = 10;    % [grid points]

% time array
dt = 2e-9;                      % [s]
t_end = 1000e-9;                 % [s]

% computation settings
input_args = {'DataCast', 'single'};


% =========================================================================
% THREE DIMENSIONAL SIMULATION
% =========================================================================

% create the computational grid
kgrid = makeGrid(Nx, dx, Ny, dy, Nz, dz);

% create the time array
kgrid.t_array = 0:dt:t_end;

% create initial pressure distribution
source.p0 = makeBall(Nx, Nx, Nx, Nx/2, Nx/2, Nx/2, source_radius);

% define a single sensor point
sensor.mask = zeros(Nx, Ny, Nz);
sensor.mask(Nx/2, Ny/2, Nz/2) = 1;

% run the simulation
sensor_data_3D = kspaceFirstOrder3D(kgrid, medium, source, sensor, input_args{:});

% =========================================================================
% VISUALISATION
% =========================================================================

figure;
[t_sc, t_scale, t_prefix] = scaleSI(t_end);
plot(kgrid.t_array*t_scale, sensor_data_3D./max(abs(sensor_data_3D)), 'k-');
xlabel(['Time [' t_prefix 's]']);
ylabel('Recorded Pressure [au]');
legend('3D');


         PAT.jobsdone.kwave = 1;
%         save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
         out.PATmat{scanIdx} = PATmat{scanIdx};
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end

end
