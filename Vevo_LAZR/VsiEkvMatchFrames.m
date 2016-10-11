function [NewFrameOrder1, NewFrameEcg1, NewFrameOrder2, NewFrameEcg2] = VsiEkvMatchFrames(FrameOrder1, FrameEcg1, FrameOrder2, FrameEcg2)

NewFrameEcg1 = FrameEcg1;
TempEcg = FrameEcg2;
NewFrameOrder1 = FrameOrder1;
TempOrder = FrameOrder2;

% Match larger dataset to smaller dataset
if (numel(FrameEcg1) < numel(FrameEcg2))
    NewFrameEcg1 = FrameEcg2;
    TempEcg = FrameEcg1;
    NewFrameOrder1 = FrameOrder2;
    TempOrder = FrameOrder1;
end

idx = zeros(1,numel(NewFrameEcg1));

for i = 1:length(NewFrameEcg1)
    tmp = NewFrameEcg1(i) - TempEcg;
    [~, idx(i)] = min(abs(tmp));
end

NewFrameOrder2 = TempOrder(idx);
NewFrameEcg2 = TempEcg(idx);

if (numel(FrameEcg1) < numel(FrameEcg2))
    t = NewFrameEcg1;
    NewFrameEcg1 = NewFrameEcg2;
    NewFrameEcg2 = t;
    f = NewFrameOrder1;
    NewFrameOrder1 = NewFrameOrder2;
    NewFrameOrder2 = f;
end