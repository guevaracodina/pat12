function [SO2] = GenerateSO2(lambda, PAMode, FrameOrder_PAMode, numFrames)

% Calculate the SO2 levels
load('MolarExtinctionCoefficient.mat');
extCoIdx = find(MolarExtinctionCoefficient == lambda(1) | MolarExtinctionCoefficient == lambda(2));
extCo = MolarExtinctionCoefficient(extCoIdx,2:3);

if (numel(PAMode{1}.Data{1}) ~= numel(PAMode{2}.Data{1}))
  error('Unequal dimensions') %Not the best check
end

numEl = numel(PAMode{1}.Data{1});
cMap = [0 linspace(0, 1, 255); 0 zeros(1,255); 0 linspace(1, 0, 255)]';

O2.Width = PAMode{1}.Width;
O2.Depth = PAMode{1}.Depth;
O2.Data = cell(1, numFrames);
DO2.Width = PAMode{1}.Width;
DO2.Depth = PAMode{1}.Depth;
DO2.Data = cell(1, numFrames);
SO2.Width = PAMode{1}.Width;
SO2.Depth = PAMode{1}.Depth;
SO2.Data = cell(1, numFrames);
figure;
for frameIdx = 1:numFrames
  
  O2.Data{frameIdx} = zeros(size(PAMode{1}.Data{FrameOrder_PAMode{1}(frameIdx)}));
  DO2.Data{frameIdx} = zeros(size(PAMode{1}.Data{FrameOrder_PAMode{1}(frameIdx)}));
  SO2.Data{frameIdx} = zeros(size(PAMode{1}.Data{FrameOrder_PAMode{1}(frameIdx)}));
  for i = 1:numEl
    if (~mod(i, 1000))
      fprintf('Frame %d/%d: Element: %d/%d\n', ...
        frameIdx, numFrames, i, numEl);
    end
    PA_Sig = [PAMode{1}.Data{FrameOrder_PAMode{1}(frameIdx)}(i); ...
      PAMode{2}.Data{FrameOrder_PAMode{2}(frameIdx)}(i)];
    if (any(PA_Sig > 300))
      tmp = extCo \ PA_Sig;
      O2.Data{frameIdx}(i) = tmp(1);
      DO2.Data{frameIdx}(i) = tmp(2);
      SO2.Data{frameIdx}(i) = tmp(1) / (tmp(1) + tmp(2));
    end
  end
  imagesc(SO2.Data{frameIdx});
  colormap(cMap); set(gca,'CLim',[0 1]);
  drawnow;
end