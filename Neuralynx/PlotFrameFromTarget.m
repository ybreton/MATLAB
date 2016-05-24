%PlotFrameFromTarget Plot 1 frame or 1 video tracker record of target information.
%
%   nlx_targets is composed of M number nlx records by N max targets per record.
%
%  The output from the ExtractFromTargets M-File provides target information in the correct format
%	for this function.
%
%   The function is passed 5 parameters:
%       x - an M by N matrix where M = the number of records and N = number of x coordinates per record.
%           this value represents the x coordinate of a given target.
%       y - an M by N matrix where M = the number of records and N = number of y coordinates per record.
%           this value represents the y coordinate of a given target.
%       color - an M by N by 7 matrix where M = the number of records and N = number of colors per record.
%           The 7 represents the 7 types of color information that is stored.
%           this value represents the color of a given target, or zero if that color is not present, or one if present.
%           color(:,:,1) = Raw Red
%           color(:,:,2) = Pure Red
%           color(:,:,3) = Raw Green
%           color(:,:,4) = Pure Green
%           color(:,:,5) = Raw Blue
%           color(:,:,6) = Pure Blue
%           color(:,:,7) = Luminance
%       valid_targets - a matrix containing the number of values for each N in the above variables.
%           this value represents the number of targets per record (which varies from record to record).
%       record_index - an integer representing an index into the above 4 matrices.  This represents which frame # to plot.
%
%
%   Example:
%    
%		Import the data from an NVT file:
%	    	>>[ts, x, y, angle, targets, points] = Nlx2MatVT('VT1.nvt', [1,1,1,1,1,1], 0, 1);
%
%       Due to Matlab limitations, processing more than about 1000 targets will take an extremely long time.  Breaking
%		the imported targets into smaller matricies is recommended.
%       >> small_target_matrix  = targets(:,1:1000);
%
%     	You can then call this function with the smaller targets matrix.
%       >> [x, y, color, valid_targets] = ExtractFromTargets(small_target_matrix);
%
%       Then call this function to display the targets with their appropriate color.
%       >> PlotFrameFromTarget(x, y, color,valid_targets,100);
%
% v1.1.0

%----------------------------------------------------------------------------------------------------------------------
%   This function plots 1 frame of targets from a video tracker record.  The user must specify the index for the record
%   in the array passed to the function.  
%----------------------------------------------------------------------------------------------------------------------
function PlotFrameFromTarget( x,y,color,valid_targets,record_index )

    num_targets = valid_targets(record_index);  % get the number of targets for the given record that are valid
    
    figure(record_index);   % index the given figure window with the same index for the specified frame
    hold on;   % make sure all targets are plotted in the same window
    
    % loop through number of targets for the given rec
    for target_index = 1:num_targets;
    
        x_coordinate = x(record_index,target_index);    % x coordinate for plotting target
        y_coordinate = y(record_index,target_index);    % y coordinate for plotting target
        
        y_coordinate = 480 - y_coordinate;  % scale the y value due to a upper left origin for the video tracker.
        
        str_color = GetColorString(color(record_index,target_index,1:7));   % gets the string of the color to plot the target
     
        plot( x_coordinate, y_coordinate, str_color);   % plot target
        
    end
    
    axis([0 720 0 480]);    % set axis for graph
    hold off;   % release the plot
    
%----------------------------------------------------------------------------------------------------------------------
%  This function returns a string containg color information for plotting the frame.  Color is chosen in a specific
%   order based on preference.  The color yellow is used to represent raw green due to the absence of a light green color string.
%----------------------------------------------------------------------------------------------------------------------
function [color_string] = GetColorString( color_array )

    if ( color_array(2) ~= 0 )      % pure red
        color_string = 'ro';
    elseif ( color_array(4) ~= 0 )  % pure green
        color_string = 'go';        
    elseif ( color_array(6) ~= 0 )  % pure blue
        color_string = 'bo';
    elseif ( color_array(5) ~= 0 )  % raw blue
        color_string = 'co';
    elseif ( color_array(1) ~= 0 )  % raw red
        color_string = 'mo';
    elseif ( color_array(3) ~= 0 )  % raw green
        color_string = 'yo';
    else                            % black for luminance or default
        color_string = 'ko';
    end
        
    