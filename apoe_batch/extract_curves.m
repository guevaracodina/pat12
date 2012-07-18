function data = extract_curves(handles, n_wavelengths, indexes)

size1_data = size(handles.acq.PAmode_data,1);
size2_data = size(handles.acq.PAmode_data,2);
size3_data = size(handles.acq.PAmode_data,3);

n_temporal_points = floor(size3_data/2);

data = zeros(n_temporal_points, n_wavelengths);

for i = 1:n_temporal_points
    for j = 1:n_wavelengths
        BfData = abs(handles.acq.PAmode_data(:,:,i*2+j-2));
        data(i,j) = sum(BfData(indexes));
    end
end

figure;plot(data(:,1),'+');
