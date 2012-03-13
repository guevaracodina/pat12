function make_geom_uniform_GPU(nx,ny,nz)

% Brique homogène visant à modéliser un slab. La brique est ensuite sauvee
% dans un fichier nomme `homogene.bin` qui est utilise comme entree par le
% programme de simluation monte-carlo (tMCimg.exe).
% 
% A ce point la taille des voxels n'est pas fixee, par contre la simulation
% monte-carlo exige que ces voxels soient cubique. Leur nombre est fixe par
% contre. Dans le fichier src.cfg, utilise par tMCimg.exe en entree, la
% taille des voxels de meme que la position de la source (et des detecteurs
% mais qui ne sont pas utilises ici) est fixee.
%
% Pour le monte-carlo, nous devons mettre une couche d'air a l'exterieur.
% Donc nous prenons des dimensions nx+2, ny+2 et nz+2 pour ensuite aller
% lire la fluence que dans le volume (et non pas dans l'air)

homog = uint8(ones(ny,nx,nz));

fid = fopen('homogene.bin', 'wb');
fwrite(fid, homog, 'uint8');
fclose(fid);
disp('make geom');