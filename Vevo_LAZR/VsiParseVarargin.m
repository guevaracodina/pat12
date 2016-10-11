function [parsedStruct] = VsiParseVarargin(paramList, varargin)
% A function to parse the variable argument list based on paramList
% criteria. If no variable stated then a default value will be used
%
% Input:
%   paramList = A cell matrix of m x 3.
%       Column 1 represents the parameter name
%       Column 2 represents the criteria (a function such as @ischar)
%       Column 3 represents the default value
%   varargin = Variable argument list.
%   
% Output:
%   parsedStruct = A structure with fields matching the column 1 paramList
%       names.

parsedStruct = [];

try
    % Do some basic checks
    if (size(paramList,2) ~= 3 || numel(paramList) == 0)
      error( 'The paramList must be a matrix of m x 3');
    end
    
    if (mod(numel(varargin), 2))
      error('The varargin parameter should have an even number of elements');
    end
    
    % Set default value
    for i = 1:size(paramList,1)
        parsedStruct.(paramList{i,1}) = paramList{i,3};
    end

    % Parse varargin
    for i = 1:2:numel(varargin)
        bParamFound = false;
        for j = 1:size(paramList,1)
            if (strcmp(varargin{i}, paramList{j,1}))
                if (paramList{j,2}(varargin{i+1}))
                    parsedStruct.(paramList{j,1}) = varargin{i+1};
                else
                    warning('Invalid parameter type for %s. Using default', varargin{i});
                end
                
                bParamFound = true;
                break;
            end
        end
        
        if (~bParamFound)
            warning('Skipping unknown parameter for %s.', varargin{i});
        end
    end 
catch err
    rethrow(err);    
end
    
end

