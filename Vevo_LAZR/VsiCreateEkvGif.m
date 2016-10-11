function VsiCreateEkvGif(Mode, FrameOrder, Filename, cMap, cMapRange, bLogCompressed, bInterpolate)

    figure;
    if (bInterpolate)
        WidthInterp = linspace(min(Mode.Width), max(Mode.Width), 128);
        DepthInterp = Mode.Depth;
        
        [X, Y] = meshgrid(Mode.Width, Mode.Depth);
        [XInterp, YInterp] = meshgrid(WidthInterp, DepthInterp);
        
        for i = 1:length(FrameOrder) 
            F = TriScatteredInterp(X(:), Y(:), Mode.Data{FrameOrder(i)}(:));
            imgDataInterp = F(XInterp, YInterp);
            if (bLogCompressed)
                imgDataInterp = 20*log10(imgDataInterp);
            end
            
            imagesc(Mode.Width, Mode.Depth, imgDataInterp, cMapRange);
            colormap(cMap);
            drawnow;

            frame = getframe;
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if i == 1;
                imwrite(imind, cm, [Filename '.gif'], 'gif', ...
                    'DelayTime', 0.03, 'Loopcount', inf);
            else
                imwrite(imind, cm, [Filename '.gif'], 'gif', ...
                    'DelayTime', 0.03, 'WriteMode', 'append');
            end
        end
    else % Not interpolated
        for i = 1:length(FrameOrder)
            imgData = Mode.Data{FrameOrder(i)};
            if (bLogCompressed)
                imgData = 20*log10(imgData);
            end
            
            imagesc(Mode.Width, Mode.Depth, imgData, cMapRange);
            colormap(cMap);
            drawnow;

            frame = getframe;
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if i == 1;
                imwrite(imind, cm, [Filename '.gif'], 'gif', ...
                    'DelayTime', 0.03, 'Loopcount', inf);
            else
                imwrite(imind, cm, [Filename '.gif'], 'gif', ...
                    'DelayTime', 0.03, 'WriteMode', 'append');
            end
        end
    end
end

