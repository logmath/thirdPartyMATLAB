function hlgd = gridlegend(varargin)
% GRIDLEGEND Create a legend arranged in a grid
%   GRIDLEGEND(RowNames,ColumnNames) creates a legend of the line objects
%   plotted on the current axes arranged in a grid, with row and column
%   headers specified by RowNames and ColumnNames, respectively.
%
%   GRIDLEGEND(haxes,...) creates a legend of the line objects plotted on
%   the axes with the handle haxes.
%
%   GRIDLEGEND(hlines,...) creates a legend of the line objects specified
%   by the array hlines. The number of rows of hlines should match the
%   length of RowNames, and the number of columns of hlines should match
%   the length of ColumnNames. If there is no line object at a certain row,
%   column index, that element in hlines should be a graphics object
%   placeholder generated by gobjects.
%
%   GRIDLEGEND(...,'Name',Value) specifices name-value pairs for formatting
%   the grid legend. See below for valid name-value pairs.
%
%   hlgd = GRIDLEGEND(...) returns the handle to the grid legend axes.
%
% INPUTS
%
% --- Required ---
%   RowNames    - Cell array of row names
%
%   ColumnNames - Cell array of column names
%
% --- Optional ---
%   haxes       - Handle to the axes on which to plot the legend. The line
%                 objects already plotted on the axes will be used to
%                 populate the legend. Note that if haxes is specified, it
%                 must be the first input argument.
%
%   hlines      - 2D array of handles to the line objects used to populate
%                 the legend. The 2D array should correspond to the layout
%                 of the grid legend. If there is no line object at a
%                 certain row, column index, that element in hlines should
%                 be a graphics object placeholder. Note that if hlines is
%                 specified, it must be the first input argument.
%
% --- Name-Value Pairs ---
%   Name          Values
%   -----------   ---------------------------------------------------------
%   Alignment   - Cell array of strings specifying the horizontal alignment
%                 of the columns in the grid legend. Options are 'right',
%                 'center', and 'left' (or 'r', 'c', and 'l').
%
%   Location    - Options include all of the options in legend (e.g.
%                 'northeast', 'northwest', 'eastoutside', etc.), but
%                 'best' and 'bestoutside' are not currently supported and
%                 will be added in a future release.
%
%   Offset      - [X,Y] vector that specifies the x- and y-offset, in
%                 pixels, to move the legend from its default location.
%
%   ** Other accepted name-value pairs: Box, Color, EdgeColor, FontName,
%      FontSize, FontWeight, Interpreter, ItemWidth, LineWidth, Parent,
%      TextColor
%   ** For more information, see documentation in build-in function legend
%
% OUTPUTS
%   hlgd        - Handle to the grid legend axes
%
% NOTES
%   Q: When should I use GRIDLEGEND?
%   A: Use GRIDLEGEND if you are plotting a large number of results that
%      could be logically arranged in a table or grid. In some cases, a
%      regular legend can be overwhelming, but GRIDLEGEND can take up less
%      space and be easier to understand. See the examples below for some
%      cases in which GRIDLEGEND is useful.
%
% EXAMPLES
%   Example: Plot the populations of several US states and use GRIDLEGEND
%   to compare the states' populations and several types of fits. See
%   Example_StatePopulation to create the plot, compare GRIDLEGEND to a
%   regular legend, and explore the features of GRIDLEGEND.
%
% See also LEGEND GOBJECTS EXAMPLE_STATEPOPULATION

% Copyright 2017-2022 Shane Lympany

% Version   | Date          | Notes
% ----------|---------------|----------------------------------------------
% 1.0.0     | 12 Mar 2018   | * Original release
% ----------|---------------|----------------------------------------------
% 1.0.1     | 23 Mar 2018   | * Added variable to independently set heights
%           |               |   of header row and table rows
% ----------|---------------|----------------------------------------------
% 1.0.2     | 23 Sep 2022   | * Corrected issue with multiple subplots by
%           |               |   turning off handle visibility
%           |               | * Added option to input custom line length in
%           |               |   legend (item size)
%           |               | * Removed restriction for all elements of
%           |               |   RowNames and ColNames cell arrays to be
%           |               |   char so that a cell within a cell prints
%           |               |   multi-line labels

% --- Read and Organize User Inputs ---------------------------------------

% Defaults
line_width = 40; % [px] width of line object in legend
margin_height = 2; % [px] vertical margin between rows
margin_width = 10; % [px] horizontal margin between columns
padding_height = 2; % [px] vertical padding at edge of legend
padding_width = 8; % [px] horizontal padding at edge of legend
margin_outer = 10; % [px] outside margin surrounding legend

% Look for optional leading inputs
if isscalar(varargin{1}) && isgraphics(varargin{1}, 'axes')
    hax = varargin{1};
    varargin = varargin(2:end);
else
    hax = [];
end
if (any(ishghandle(varargin{1}(:))) && any(arrayfun(@(x)isa(x,'matlab.graphics.mixin.Legendable'),varargin{1}(:))))
    hobj = varargin{1};
    varargin = varargin(2:end);
else
    hobj = [];
end

% Parse inputs
p = inputParser;
p.FunctionName = 'gridlegend';
addRequired(p,'RowNames',@(x)(ischar(x) || iscell(x)));
addRequired(p,'ColumnNames',@(x)(ischar(x) || iscell(x)));
addParameter(p,'Alignment','',@(x)(ischar(x) || (iscell(x) && all(cellfun(@ischar,x)))));
addParameter(p,'Box','',@(x)(ischar(x) && any(strcmpi(x,{'on','off'}))));
addParameter(p,'Color','',@(x)(any(strcmpi(x,{'k','b','r','g','c','m','y','w','none'})) || (isnumeric(x) && numel(x) == 3)));
addParameter(p,'EdgeColor','',@(x)(any(strcmpi(x,{'k','b','r','g','c','m','y','w','none'})) || (isnumeric(x) && numel(x) == 3)));
addParameter(p,'FontAngle','',@(x)(ischar(x) && any(strcmpi(x,{'normal','italic'}))));
addParameter(p,'FontName','',@ischar);
addParameter(p,'FontSize',[],@isnumeric);
addParameter(p,'FontWeight','',@ischar);
addParameter(p,'Interpreter','',@ischar);
addParameter(p,'ItemSize',line_width,@isnumeric);
addParameter(p,'LineWidth',[],@isnumeric);
addParameter(p,'Location','',@ischar);
addParameter(p,'Offset',[],@(x)(isnumeric(x) && numel(x) == 2));
addParameter(p,'Parent',[],@(x)(ishghandle(x) && isa(x,'matlab.graphics.axis.Axes')));
addParameter(p,'TextColor','',@(x)(any(strcmpi(x,{'k','b','r','g','c','m','y','w','none'})) || (isnumeric(x) && numel(x) == 3)));
addParameter(p,'Visible','',@(x)(ischar(x) && any(strcmpi(x,{'on','off'}))));
p.KeepUnmatched = true;
parse(p,varargin{:});
in = p.Results;

% Format row and column names
if ischar(in.RowNames)
    in.RowNames = {in.RowNames};
end
if ischar(in.ColumnNames)
    in.ColumnNames = {in.ColumnNames};
end

% Get handles to axes and line objects
if isempty(hax) && isempty(hobj)
    if ~isempty(in.Parent)
        hax = in.Parent;
    elseif isempty(findobj('Type','axes','-not','Tag','legend'))
        return;
    else
        hax = findobj('Parent',gcf,'Type','axes','-not','Tag','legend');
        if isempty(hax)
            return;
        end
        hax = hax(1);
    end
    hobj = findobj(hax);
    islegendable = false(size(hobj));
    for i = 1:numel(hobj)
        islegendable(i) = isa(hobj(i),'matlab.graphics.mixin.Legendable');
    end
    hobj = hobj(islegendable);
    hobj = hobj(end:-1:1);
elseif isempty(hax) && ~isempty(hobj)
    if ~isempty(in.Parent)
        hax = in.Parent;
    else
        hax = get(hobj(1),'Parent');
    end
elseif ~isempty(hax) && isempty(hobj)
    hobj = findobj(hax);
    islegendable = false(size(hobj));
    for i = 1:numel(hobj)
        islegendable(i) = isa(hobj(i),'matlab.graphics.mixin.Legendable');
    end
    hobj = hobj(islegendable);
    hobj = hobj(end:-1:1);
end
hfig = ancestor(hax,'matlab.ui.Figure');

% Delete existing legend
delete(findobj('Parent',hfig,'Type','legend'));
delete(findobj('Parent',hfig,'Type','axes','-and','Tag','legend'));

% Extract legend properties
if strcmpi(in.Box,'off')
    legend_properties.Box = 'off';
    if ~isempty(in.EdgeColor)
        legend_properties.XColor = in.EdgeColor;
        legend_properties.YColor = in.EdgeColor;
    else
        legend_properties.XColor = 'none';
        legend_properties.YColor = 'none';
    end
    if ~isempty(in.Color)
        legend_properties.Color = in.Color;
    else
        legend_properties.Color = 'none';
    end
else
    legend_properties.Box = 'on';
    if ~isempty(in.EdgeColor)
        legend_properties.XColor = in.EdgeColor;
        legend_properties.YColor = in.EdgeColor;
    else
        legend_properties.XColor = hax.XColor;
        legend_properties.YColor = hax.XColor;
    end
    if ~isempty(in.Color)
        legend_properties.Color = in.Color;
    else
        legend_properties.Color = hax.Color;
    end
end
if ~isempty(in.LineWidth)
    legend_properties.LineWidth = in.LineWidth;
else
    legend_properties.LineWidth = 0.5;
end

% Extract text properties
if ~isempty(in.FontAngle)
    text_properties.FontAngle = in.FontAngle;
else
    text_properties.FontAngle = 'normal';
end
if ~isempty(in.FontName)
    text_properties.FontName = in.FontName;
else
    text_properties.FontName = hax.FontName;
end
if ~isempty(in.FontSize)
    text_properties.FontSize = in.FontSize;
else
    text_properties.FontSize = hax.FontSize;
end
if ~isempty(in.FontWeight)
    text_properties.FontWeight = in.FontWeight;
else
    text_properties.FontWeight = hax.FontWeight;
end
if ~isempty(in.Interpreter)
    text_properties.Interpreter = in.Interpreter;
else
    text_properties.Interpreter = 'tex';
end
if ~isempty(in.TextColor)
    text_properties.Color = in.TextColor;
else
    text_properties.Color = [0 0 0];
end

% Extract location properties
if ~isempty(in.Location)
    location = in.Location;
else
    location = 'NorthEast';
end
if ~isempty(in.Offset)
    offset = in.Offset;
else
    offset = [0 0];
end

% Create alignment cell array
if ~isempty(in.Alignment)
    if ischar(in.Alignment)
        in.Alignment = [{'left'} repmat({in.Alignment},1,length(in.ColumnNames))];
    elseif iscell(in.Alignment) && length(in.Alignment) == 1
        in.Alignment = [{'left'} repmat(in.Alignment,1,length(in.ColumnNames))];
    elseif iscell(in.Alignment) && length(in.Alignment) == length(in.ColumnNames)
        in.Alignment = [{'left'} in.Alignment];
    elseif iscell(in.Alignment) && length(in.Alignment) ~= length(in.ColumnNames)+1
        error('Lengths of Alignment and ColumnNames options are not compatible.\n');
    end
else
    in.Alignment = [{'left'} repmat({'center'},1,length(in.ColumnNames))];
end
for i = 1:length(in.Alignment)
    switch lower(in.Alignment{i})
        case {'left','l'}
            in.Alignment{i} = 'left';
        case {'center','c'}
            in.Alignment{i} = 'center';
        case {'right','r'}
            in.Alignment{i} = 'right';
        otherwise
            error('Invalid alignment string; options are ''left'', ''center'', and ''right''.\n');
    end
end

% Create grid of objects
nrows = length(in.RowNames);
ncols = length(in.ColumnNames);
if length(hobj) == numel(hobj)
    N = nrows*ncols;
    if length(hobj) > N
        error('Not enough row and column names specified.\n');
    end
    hobj = reshape([hobj(:); gobjects(N - numel(hobj),1)],nrows,ncols);
else
    if size(hobj,1) ~= nrows || size(hobj,2) ~= ncols
        error('Number of row and column names do not match number of entries.\n');
    end
end


% --- Create Legend -------------------------------------------------------

% Create invisible legend axes
hlgd = axes(...
    'Parent',hfig,...
    'Units','pixels',...
    'Position',[0 0 0 0],...
    'XTick',[],...
    'YTick',[],...
    'Tag','legend',...
    'Visible','off',...
    'NextPlot','add',...
    'HandleVisibility','off',...
    legend_properties);

% Create text boxes for row and column names
hrows = zeros(nrows,1);
hcols = zeros(1,ncols);
for i = 1:length(in.RowNames)
    hrows(i) = text(0,0,in.RowNames{i},...
        'Parent',hlgd,...
        'Units','pixels',...
        'HorizontalAlignment',in.Alignment{1},...
        'VerticalAlignment','middle',...
        text_properties);
end
for i = 1:length(in.ColumnNames)
    hcols(i) = text(0,0,in.ColumnNames{i},...
        'Parent',hlgd,...
        'Units','pixels',...
        'HorizontalAlignment',in.Alignment{i+1},...
        'VerticalAlignment','middle',...
        text_properties);
end
hrows = handle(hrows);
hcols = handle(hcols);

% Get extent of text boxes
rowname_extent = cat(1,hrows.Extent);
colname_extent = cat(1,hcols.Extent);
row_height = ceil(max(rowname_extent(:,4)));
row_height_headers = ceil(max(colname_extent(:,4)));
col_width = ceil([max(rowname_extent(:,3)) max(colname_extent(:,3)',in.ItemSize)]);

% Get total extent of the legend
total_height = row_height_headers + nrows*row_height + nrows*margin_height + 2*padding_height;
total_width = sum(col_width) + ncols*margin_width + 2*padding_width;

% Set legend location
hlgd = locateLegend(hax,hlgd,location,offset,total_width,total_height,margin_outer);
set(hfig,'ResizeFcn',{@resizeFigure,hax,hlgd,location,offset,total_width,total_height,margin_outer});

% Set legend properties
hlgd.XLim = [0 total_width];
hlgd.YLim = [0 total_height];
hlgd.XTick = [];
hlgd.YTick = [];

% Iterate through grid
for i = 1:nrows+1
    for k = 1:ncols+1
        
        % X-coordinates
        x_left = (k-1)*margin_width + padding_width + sum(col_width(1:k-1));
        x_right = x_left + col_width(k);
        x_center = (x_left + x_right)/2;
        
        % Y-coordinates
        y_bottom = (nrows+1-i)*(row_height+margin_height) + padding_height;
        if i == 1
            y_top = y_bottom + row_height_headers;
        else
            y_top = y_bottom + row_height;
        end
        y0 = (y_bottom + y_top)/2;
        
        % Set x-coordinate based on alignment
        switch lower(in.Alignment{k})
            case 'left'
                x0 = x_left;
                xplot = [x0 x0+in.ItemSize];
            case 'center'
                x0 = x_center;
                xplot = [x0-in.ItemSize/2 x0+in.ItemSize/2];
            case 'right'
                x0 = x_right;
                xplot = [x0-in.ItemSize x0];
        end
        
        % Move row or column name or plot line
        if i == 1 && k == 1
            continue;
        elseif i == 1
            hcols(k-1).Position = [x0 y0 0];
        elseif k == 1
            hrows(i-1).Position = [x0 y0+margin_height 0];
        elseif ~isa(hobj(i-1,k-1),'matlab.graphics.GraphicsPlaceholder')
            plot(hlgd,xplot,[y0 y0],...
                'Color',hobj(i-1,k-1).Color,...
                'LineStyle',hobj(i-1,k-1).LineStyle,...
                'LineWidth',hobj(i-1,k-1).LineWidth);
            plot(hlgd,sum(xplot)/2,y0,...
                'LineStyle','none',...
                'LineWidth',hobj(i-1,k-1).LineWidth,...
                'Color',hobj(i-1,k-1).Color,...
                'Marker',hobj(i-1,k-1).Marker,...
                'MarkerEdgeColor',hobj(i-1,k-1).MarkerEdgeColor,...
                'MarkerFaceColor',hobj(i-1,k-1).MarkerFaceColor,...
                'MarkerSize',hobj(i-1,k-1).MarkerSize);
        end
    end
end

% Make legend visible
hlgd.Visible = 'on';
uistack(hlgd,'top');

% Set output variables
if nargout == 0
    clear hlgd
end

end


function [hlgd,x_corner,y_corner] = locateLegend(hax,hlgd,location,offset,total_width,total_height,margin_outer)
    
    % Get figure dimensions in pixels
    old_units = hax.Parent.Units;
    hax.Parent.Units = 'pixels';
    fig_width = hax.Parent.Position(3);
    fig_height = hax.Parent.Position(4);
    hax.Parent.Units = old_units;
    
    % Set axes units to pixels
    old_units = hax.Units;
    hax.Units = 'pixels';

    % Set legend location
    switch lower(location)
        case {'northeast','ne'}
            x_corner = sum(hax.Position([1 3])) - margin_outer - total_width + offset(1);
            y_corner = sum(hax.Position([2 4])) - margin_outer - total_height + offset(2);
        case {'north','n'}
            x_corner = (sum(hax.Position([1 3])) + hax.Position(1))/2 - total_width/2 + offset(1);
            y_corner = sum(hax.Position([2 4])) - margin_outer - total_height + offset(2);
        case {'northwest','nw'}
            x_corner = hax.Position(1) + margin_outer + offset(1);
            y_corner = sum(hax.Position([2 4])) - margin_outer - total_height + offset(2);
        case {'west','w'}
            x_corner = hax.Position(1) + margin_outer + offset(1);
            y_corner = (sum(hax.Position([2 4])) + hax.Position(2))/2 - total_height/2 + offset(2);
        case {'southwest','sw'}
            x_corner = hax.Position(1) + margin_outer + offset(1);
            y_corner = hax.Position(2) + margin_outer + offset(2);
        case {'south','s'}
            x_corner = (sum(hax.Position([1 3])) + hax.Position(1))/2 - total_width/2 + offset(1);
            y_corner = hax.Position(2) + margin_outer + offset(2);
        case {'southeast','se'}
            x_corner = sum(hax.Position([1 3])) - margin_outer - total_width + offset(1);
            y_corner = hax.Position(2) + margin_outer + offset(2);
        case {'east','e'}
            x_corner = sum(hax.Position([1 3])) - margin_outer - total_width + offset(1);
            y_corner = (sum(hax.Position([2 4])) + hax.Position(2))/2 - total_height/2 + offset(2);
        case {'northeastoutside','neo'}
            hax.OuterPosition(3) = max(1,fig_width - (total_width + margin_outer));
            x_corner = sum(hax.Position([1 3])) + margin_outer + offset(1);
            y_corner = sum(hax.Position([2 4])) - total_height + offset(2);
        case {'northoutside','no'}
            hax.OuterPosition(4) = max(1,fig_height - (total_height + margin_outer));
            x_corner = (sum(hax.Position([1 3])) + hax.Position(1))/2 - total_width/2 + offset(1);
            y_corner = sum(hax.Position([2 4])) + margin_outer + offset(2);
        case {'northwestoutside','nwo'}
            new_pos = min(fig_width-1,total_width + margin_outer);
            hax.OuterPosition([1 3]) = [new_pos min(fig_width,hax.OuterPosition(3) - (new_pos - hax.OuterPosition(1)))];
            x_corner = hax.Position(1) - hax.TightInset(1) - total_width - margin_outer + offset(1);
            y_corner = sum(hax.Position([2 4])) - total_height + offset(2);
        case {'westoutside','wo'}
            new_pos = min(fig_width-1,total_width + margin_outer);
            hax.OuterPosition([1 3]) = [new_pos min(fig_width,hax.OuterPosition(3) - (new_pos - hax.OuterPosition(1)))];
            x_corner = hax.Position(1) - hax.TightInset(1) - total_width - margin_outer + offset(1);
            y_corner = (sum(hax.Position([2 4])) + hax.Position(2))/2 - total_height/2 + offset(2);
        case {'southwestoutside','swo'}
            new_pos = min(fig_width-1,total_width + margin_outer);
            hax.OuterPosition([1 3]) = [new_pos min(fig_width,hax.OuterPosition(3) - (new_pos - hax.OuterPosition(1)))];
            x_corner = hax.Position(1) - hax.TightInset(1) - total_width - margin_outer + offset(1);
            y_corner = hax.Position(2) + offset(2);
        case {'southoutside','so'}
            new_pos = min(fig_height-1,total_height + margin_outer);
            hax.OuterPosition([2 4]) = [new_pos min(fig_height,hax.OuterPosition(4) - (new_pos - hax.OuterPosition(2)))];
            x_corner = (sum(hax.Position([1 3])) + hax.Position(1))/2 - total_width/2 + offset(1);
            y_corner = hax.Position(2) - hax.TightInset(2) - total_height - margin_outer + offset(2);
        case {'southeastoutside','seo'}
            hax.OuterPosition(3) = max(1,fig_width - (total_width + margin_outer));
            x_corner = sum(hax.Position([1 3])) + margin_outer + offset(1);
            y_corner = hax.Position(2) + offset(2);
        case {'eastoutside','eo'}
            hax.OuterPosition(3) = max(1,fig_width - (total_width + margin_outer));
            x_corner = sum(hax.Position([1 3])) + margin_outer + offset(1);
            y_corner = (sum(hax.Position([2 4])) + hax.Position(2))/2 - total_height/2 + offset(2);
        case {'best','b'} % !!! TODO
            x_corner = sum(hax.Position([1 3])) - margin_outer - total_width;
            y_corner = sum(hax.Position([2 4])) - margin_outer - total_height;
        case {'bestoutside','bo'} % !!! TODO
            hax.OuterPosition(3) = max(1,fig_width - (total_width + margin_outer));
            x_corner = sum(hax.Position([1 3])) + margin_outer + offset(1);
            y_corner = (sum(hax.Position([2 4])) + hax.Position(2))/2 - total_height/2 + offset(2);
        otherwise % northeast
            x_corner = sum(hax.Position([1 3])) - margin_outer - total_width;
            y_corner = sum(hax.Position([2 4])) - margin_outer - total_height;
    end
    
    % Move legend
    hlgd.Position = [x_corner y_corner total_width total_height];
    
    % Reset axes units
    hax.Units = old_units;

end

function resizeFigure(varargin)

    % Call legend location function
    locateLegend(varargin{3:end});

end