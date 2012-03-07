function make_simulation_cfg_GPU(src_pos, det_pos, dir, rad,dx,nx,ny,nz,mua1,mus1)
% This script generate all cfg files for the LOT system in order to compute
% the sensitivity matrices.

disp('Generating files for sensitivity profiles computation')

% We create the file src.cfg for the Monte-Carlo simulation by reading
% template.cfg and adding relevant information
filename=['qtest.inp'];
fid = fopen(filename,'w');
fprintf(fid,'1000000              # total photon (not used)\n');
fprintf(fid,'29012392             # RNG seed, negative to generate\n');
fprintf(fid,'%d %d %.2f 1             # source position (mm)\n',...
    src_pos(1),src_pos(2),src_pos(3) );
fprintf(fid,'%.2f %.2f %.2f                # initial directional vector\n',...
    dir(1), dir(2), dir(3));
fprintf(fid,'0.e+00 1.e-09 1.e-9  # time-gates(s): start, end, step\n');
fprintf(fid,'homogene.bin     # volume (''uchar'' format)\n');

fprintf(fid,'%.2f %d 1 %d            # x: voxel size, dim, start/end indices\n',...
    dx, nx, nx);
fprintf(fid,'%.2f %d 1 %d            # y: voxel size, dim, start/end indices\n',...
    dx, ny, ny); 
fprintf(fid,'%.2f %d 1 %d            # z: voxel size, dim, start/end indices\n',...
    dx, nz, nz);
fprintf(fid,'1                    # num of media\n');
fprintf(fid,'%.1f %.1f %.3f %.1f  # scat(1/mm), g, mua (1/mm), n\n',...
    mus1, 0.71, mua1, 1.44);
fprintf(fid,'1	%.3f            # detector number and radius (mm)\n',...
    rad);
fprintf(fid,'%.1f	%.1f	%.1f  # detector 1 position (mm)\n',...
    det_pos(1), det_pos(2), det_pos(3));



