function data = extract_curves_threshold(handles, n_wavelengths, indexes, threshold_level)

size1_data = size(handles.acq.PAmode_data,1);
size2_data = size(handles.acq.PAmode_data,2);
size3_data = size(handles.acq.PAmode_data,3);

n_temporal_points = floor(size3_data/2);

data = zeros(n_temporal_points, n_wavelengths);

frame_data = zeros(length(indexes),1);

for i = 1:n_temporal_points
    for j = 1:n_wavelengths
        BfData = abs(handles.acq.PAmode_data(:,:,i*2+j-2));
        roi_data = BfData(indexes);
        
        edge_bin = threshold_level * 0.1 * max(roi_data);
        indices_subgroup = find(roi_data > edge_bin);
        
        data(i,j) = sum(roi_data(indices_subgroup))./length(indices_subgroup);        
    end
end


