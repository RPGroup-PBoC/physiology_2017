% Point at directory containing the data
csvDir = '../../data/csv/';

% Next we list all the csv files contain in csvDir
files = dir([csvDir '*.csv'])

%%
% Read the csv files into matlab
df = readtable([csvDir files(7).name]);

% Add log FSC and log SSC
df.logFSC = log(df.FSC_H);
df.logSSC = log(df.SSC_H);

df(1:2, :)
%%

% Let's look at the front and side scattering

scatter(df.FSC_H, df.SSC_H)
set(gca, 'xscale', 'log', 'yscale', 'log')
xlabel('Front scattering (a.u.)')
ylabel('Side scattering (a.u.')

%%
% Let's make a fancy scatter plot of the scattering

scatplot(df.FSC_H, df.SSC_H)
set(gca, 'xscale', 'log', 'yscale', 'log')
xlabel('Front scattering (a.u.)')
ylabel('Side scattering (a.u.')

%%
% Let's try instead in log scale
scatplot(df.logFSC, df.logSSC)
xlabel('log front scattering (a.u.)')
ylabel('log side scattering (a.u.')


%%

% Save my data as log of the data
% logdf = table2array(df(:, {'logFSC', 'logSSC'}));
x = table2array(df(:, 'logFSC'));
y = table2array(df(:, 'logSSC'));
%%

% Let's plot a 3d histogram because again Victoria is making my life hard
hist3([x y], [50 50])

%%
% Compute the 2D histogram keeping track of the bin counts and the
% coordinates at which these bins exist
[number xEdge yEdge] = histcounts2(x, y, [100 100]);

% Make a 2D histogram to bin the data
pcolor(number')
ylabel('side scattering')
xlabel('front scattering')
%%
% Find non-zerio elements of the histogram to speed up the calculation.
[nRow, nCol, nValue] = find(number);
   

%%
% Generate data frame with the x and y box coordinate along with the 
% bin count for the non-zero bins

% Initialize array to save xmin, xmax, ymin, ymax and the bin count
bins = zeros([length(nRow), 5]);

% save xmin
bins(:, 1) = xEdge(nRow);

% save xmax
bins(:, 2) = xEdge(nRow + 1);

% save ymin
bins(:, 3) = yEdge(nCol);

% save ymax
bins(:, 4) = yEdge(nCol + 1);

% save the bin counts
bins(:, 5) = nValue;

% Let's convert bins into a fancy table with headers
dfSort = array2table(bins, 'VariableName',...
                    {'xmin' 'xmax' 'ymin' 'ymax' 'count'})



% dfSort = table(xEdge(nRow)', xEdge(nRow + 1)',...
%                yEdge(nCol)', yEdge(nCol + 1)', nValue,...
%                 'VariableNames', {'xvalmin' 'xvalmax' 'yvalmin'...
%                                   'yvalmax', 'count'});

%%
% Sort the data frame by the bin count
dfSort = sortrows(dfSort, 'count', 'descend');

% Add column with cumulative fraction of data
dfSort.cumfrac = cumsum(dfSort.count) / sum(dfSort.count);

%%
% Define fraction of the data I want to keep.
frac = 0.4;

% Generate boolean array to know which bins to keep
binsToKeep = dfSort.cumfrac <= frac;

% Keep only the bins that satisfied the percentage condition
dfKept = dfSort(binsToKeep, :);

% Initialize an array to keep track of which data points we will keep
idx = zeros([height(df), 1]);

%%
% generate a for loop to loop through each of the bins
for i=1:height(dfKept)
    % Generate the box boundaries
    xmin = table2array(dfKept(i, 'xmin'));
    xmax = table2array(dfKept(i, 'xmax'));
    ymin = table2array(dfKept(i, 'ymin'));
    ymax = table2array(dfKept(i, 'ymax'));
    
    % Check which data points fall inside the box
    inBox = x > xmin & x < xmax & y > ymin & y < ymax;
    % update the boolean array to know which data passed the filter
    idx = idx | inBox;
end %for

%%
% apply gate
gatedf = df(idx, :);

%%

% gatedf = unsupervised_gating(df, 0.01, [500 500], 'FSC_H', 'SSC_H', true);

scatplot(df.logFSC, df.logSSC)
hold on
scatter(log(gatedf.FSC_H), log(gatedf.SSC_H), 'r.')
xlabel('Front scattering (a.u.)')
ylabel('Side scattering (a.u.)')
hold off


