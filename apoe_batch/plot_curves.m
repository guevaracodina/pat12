cell_filenames = {'pre1' 'pre2' 'pre3' 'post1' 'post2' 'post3'};
inverse_flag = [0 0 0 1 1 1];
pre_flag = [0 0 1 0 0 0];
plot_on_same = false;
inverse_bool = true;
normalize_bool = true;

ylim1 = 0;
ylim2 = 2;

n_files = length(cell_filenames);
data_y1 = [];
data_y_filtered1 = [];
data_y2 = [];
data_y_filtered2 = [];
line_coords = [];

for index = 1:n_files
    
    filename = cell_filenames{index};
    load(filename);
       
    if (inverse_bool)  
        if (inverse_flag(index))
            temp_y = zeros(size(y1));
            temp_y = y1;
            y1 = y2;
            y2 = temp_y;
            
            temp_y_filtered = zeros(size(y1));
            temp_y_filtered = y_filtered1;
            y_filtered1 = y_filtered2;
            y_filtered2 = temp_y_filtered;
        end
    end
    
    if (pre_flag(index))
        mean_y1_filtered = mean(y_filtered1);
        mean_y2_filtered = mean(y_filtered2);
    end
    
    data_y1 = vertcat(data_y1,y1);
    data_y2 = vertcat(data_y2,y2); 
    data_y_filtered1 = vertcat(data_y_filtered1,y_filtered1);
    data_y_filtered2 = vertcat(data_y_filtered2,y_filtered2);
    line1_coords = [length(y1)];
    line_coords = vertcat(line_coords, line1_coords);

end

if (normalize_bool)
    data_y_filtered1 = data_y_filtered1/mean_y1_filtered;
    data_y_filtered2 = data_y_filtered2/mean_y2_filtered;
    data_y1 = data_y1/mean_y1_filtered;
    data_y2 = data_y2/mean_y2_filtered;
end


if (plot_on_same)
    
    figure;
    plot(data_y1,'r:');
    hold on
    plot(data_y_filtered1,'r-','LineWidth',2);
    test = cumsum(line_coords);
    for index = 1:n_files-1
        X = [test(index) test(index)];
        Y = [ylim1 ylim2];
        line_separation = line(X,Y);
        
        if (pre_flag(index))
            set(line_separation, 'Color','r');
        end
    end
    
    plot(data_y2,'k:');
    plot(data_y_filtered2,'k-','LineWidth',2);
    ylim([ylim1 ylim2]);
    
    
    test = cumsum(line_coords);
    for index = 1:n_files-1
        X = [test(index) test(index)];
        Y = [ylim1 ylim2];
        line_separation = line(X,Y);
        
        if (pre_flag(index))
            set(line_separation, 'Color','r');
        end
    end 
    
else
    figure;
    subplot(2,2,1)

    plot(data_y1,'r:');
    title('\lambda_1');
    hold on
    plot(data_y_filtered1,'r-','LineWidth',2);
    test = cumsum(line_coords);
    for index = 1:n_files-1
        X = [test(index) test(index)];
        Y = [ylim1 ylim2];
        line_separation = line(X,Y);
        
        if (pre_flag(index))
            set(line_separation, 'Color','r');
        end
    end
    
    subplot(2,2,2)
    hold on
    plot(data_y2,'k:');
    plot(data_y_filtered2,'k-','LineWidth',2);
    ylim([ylim1 ylim2]);
    title('\lambda_2');
    
    test = cumsum(line_coords);
    for index = 1:n_files-1
        X = [test(index) test(index)];
        Y = [ylim1 ylim2];
        line_separation = line(X,Y);
        
        if (pre_flag(index))
            set(line_separation, 'Color','r');
        end
    end
    
    %3rd curve
    y_divided_filtered = data_y_filtered1 ./ data_y_filtered2;
    subplot(2,2,3)
    hold on
    plot(y_divided_filtered,'k-','LineWidth',1);
    ylim([ylim1 ylim2]);
    title('\lambda_1/\lambda_2');
    
    test = cumsum(line_coords);
    for index = 1:n_files-1
        X = [test(index) test(index)];
        Y = [ylim1 ylim2];
        line_separation = line(X,Y);
        
        if (pre_flag(index))
            set(line_separation, 'Color','r');
        end
    end   
    
    %4th curve
    y_divided_refiltered = smooth(y_divided_filtered, 20, 'moving');
    subplot(2,2,4)
    hold on
    plot(y_divided_refiltered,'k-','LineWidth',1);
    ylim([ylim1 ylim2]);
    title('\lambda_1/\lambda_2 smoothed');
    
    test = cumsum(line_coords);
    for index = 1:n_files-1
        X = [test(index) test(index)];
        Y = [ylim1 ylim2];
        line_separation = line(X,Y);
        
        if (pre_flag(index))
            set(line_separation, 'Color','r');
        end
    end
end 