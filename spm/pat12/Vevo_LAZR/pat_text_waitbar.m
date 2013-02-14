function pat_text_waitbar(varargin)
% Shows a non-graphical progress indication.
% 
% Prior to the for-loop, you should call:
% pat_text_waitbar(0, 'Please wait...');
% 
% In each iteration of the for-loop, you should call:
% for iX = 1:nX
%     % Update progress bar
%     pat_text_waitbar(iX/nX, sprintf('Processing event %d from %d', iX, nX));
% end
% 
% After finishing the for-loop, you should call
% pat_text_waitbar('Clear');
% 
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

if ischar(varargin{1}),
    pat_cumdisp;
elseif ~varargin{1},
    pat_cumdisp;
    disp(varargin{2});
else
    pat_cumdisp([num2str(100*varargin{1},'%3.1f'),'% ' varargin{2}]);
end
end % End pat_text_waitbar

function pat_cumdisp(txt)
% pat_cumdisp persistent text display
% pat_cumdisp;          initializes persistent display
% pat_cumdisp(txt);     displays persistent text
%
persistent oldtxt;

if nargin<1,
    oldtxt = ''; 
    fprintf(1,'\n'); 
else
    fprintf(1,[repmat('\b',[1,length(oldtxt)]),'%s'],txt);
    oldtxt = sprintf('%s',txt);
end
end % end pat_cumdisp

% EOF
