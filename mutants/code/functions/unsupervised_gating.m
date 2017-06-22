function gatedf = unsupervised_gating(df, frac, nbins, xVal, yVal, logScale)
% Automatically gates the data based on the density of the dat points on
% the xVal and yVal 2D histogram.
% Parameters
% ----------
% df : table
%     table containing the raw data to be gated. This must be a table object
%     since the name of the column will be used to decide on which columns
%     to apply the gate.
% frac : float. (0, 1).
%     fraction of the data to be kept after applying the gate. This should
%     be a number between 0 and 1.
% nbins : array. size (2, 1)
%     number of bins to use on the x axis and y axis.
% xVal : string.
%     Name of the column in df that contains the x values that will be used
%     for the gating.
% yVal : string.
%     Name of the column in df that contains the y values that will be used
%     for the gating.
% logScale : bool.
%     Boolean indicating if the gating should be performed using the log
%     of the indicated xVal and yVal values.
% Returns
% -------
% gateddf : table.
%     Table that keeps the values that passed the criteria applied by the
%     gating.
    
    % Determine the x and y values on which to perform the gating.
    % Check if the log scale should be applied or not.
    if logScale
        x = log(table2array(df(:, xVal)));
        y = log(table2array(df(:, yVal)));
    else
        x = table2array(df(:, xVal));
        y = table2array(df(:, yVal));
    end %if
    
    % Compute the 2D histogram keeping track of the bin counts and the
    % coordinates at which these bins exist
%     [number, center] = hist3([x y], nbins);

    [number xEdge yEdge] = histcounts2(x, y, nbins);
    % extract the center of the bins into reasonable variables
    
%     xCenter = [center{1}];
%     yCenter = [center{2}];

    % Find non-zerio elements of the histogram to speed up the calculation.
    [nRow, nCol, nValue] = find(number);

    % Generate data frame with the x and y coordinate along with the bin
    % count for the non-zero bins
%     dfSort = table(xEdge(nRow)', yEdge(nCol)', nValue,...
%                     'VariableNames', {xVal yVal 'count'});
    dfSort = table(xEdge(nRow)', xEdge(nRow + 1)',...
                   yEdge(nCol)', yEdge(nCol + 1)', nValue,...
                    'VariableNames', {'xvalmin' 'xvalmax' 'yvalmin'...
                                      'yvalmax', 'count'});



    % Sort the data frame by the bin count
    dfSort = sortrows(dfSort, 'count', 'descend');
    
    % Add column with cumulative fraction of data
    dfSort.cumfrac = cumsum(dfSort.count) / sum(dfSort.count);
    
    % define the inter-bin distance
%     xbinDist = diff(x);
%     xbinDist = xbinDist(1);
%     ybinDist = diff(y);
%     ybinDist = ybinDist(1);
    
    % Generate boolean array to know which bins to keep
    binsToKeep = dfSort.cumfrac <= frac;

    % Keep only the bins that satisfied the percentage condition
    dfKept = dfSort(binsToKeep, :);
        
    % Initialize an array to keep track of which data points we will keep
    idx = zeros([height(df), 1]);

    % generate a for loop to loop through each of the bins
    for i=1:height(dfKept)
        % Generate the box boundaries
        xmin = table2array(dfKept(i, 'xvalmin'));
        xmax = table2array(dfKept(i, 'xvalmax'));
        ymin = table2array(dfKept(i, 'yvalmin'));
        ymax = table2array(dfKept(i, 'yvalmax'));
%         xcent = table2array(dfKept(i, xVal));
%         ycent = table2array(dfKept(i, yVal));
%         xbin = [xcent - (xbinDist / 2); xcent + (xbinDist / 2)];
%         ybin = [ycent - (ybinDist / 2); ycent + (ybinDist / 2)];
        % Find which data points are inside the box
%         [inBox, outbox] = inpolygon(x, y, xbin, ybin);
        inBox = x > xmin & x < xmax & y > ymin & y < ymax;
        % update the boolean array to know which data passed the filter
        idx = idx | inBox;
    end %for
    
    % apply gate
    gatedf = df(idx, :);
end %function