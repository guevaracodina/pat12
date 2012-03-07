function j = tiff_frames(fn)
%
% n = tiff_frames(filename)
%
% Returns the number of slices in a TIFF stack.
%
%

status = 1; j=0;
jstep = 10^3;
while status
    try
        j=j+jstep;
        imread(fn,j);
    catch
        if jstep>1
            j=j-jstep;
            jstep = jstep/10;
        else
            j=j-1;
            status = 0;
        end
    end
end
end
