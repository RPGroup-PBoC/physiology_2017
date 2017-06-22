% Point at directory containing the data
csvDir = '../data/csv/';

% Next we list all the csv files contain in csvDir
files = dir([csvDir '*.csv'])

%%
% Read the csv files into matlab
df = readtable([csvDir files(7).name]);

% Add log FSC and log SSC
df.logFSC = log(df.FSC_H);
df.logSSC = log(df.SSC_H);

df(1:3, :)

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
scatplot(df.logFSC, df.logSSC)
xlabel('Front scattering (a.u.)')
ylabel('Side scattering (a.u.')
%%

% Victoria wants to make my life very hard. Challenge accepted!

% Save my data as log of the data
logdf = table2array(df(:, {'logFSC', 'logSSC'}));

%%

% Let's plot a 3d histogram because again Victoria is making my life hard
hist3(logdf, [50, 50])

%%

% Make a 2D histogram to bin the data
[number, center] = hist3(logdf, [50 50]);
pcolor(center{1}, center{2}, number')
ylabel('side scattering')
xlabel('front scattering')

%%
% extract the center of the bins into reasonable variables
fscCenter = [center{1}];
sscCenter = [center{2}];

% Find non-zerio elements of the histogram to speed up the calculation.
[nRow, nCol, nValue] = find(number);


% Initialize data frame to save coordinates and bin count
% sortdf = zeros([length(fscCenter) * length(sscCenter), 4]);
sortdf = zeros([length(nValue), 4]);

%%
for i=1:length(nValue)
    % Add the fsc and ssc value to the sortdf array
        sortdf(i, 1) = fscCenter(nRow(i));
        sortdf(i, 2) = sscCenter(nCol(i));
        % Add the bin count
        sortdf(i, 3) = nValue(i);
        % Add the fraction of data that each bin contains
        sortdf(i, 4) = nValue(i) / sum(nValue);
end %for

%%
% initialize a counter
% counter = 1;
% for i=1:length(fscCenter)
%     for j=1:length(sscCenter)
%         % Add the fsc and ssc value to the sortdf array
%         sortdf(counter, 1) = fscCenter(i);
%         sortdf(counter, 2) = sscCenter(j);
%         % Add the bin count
%         sortdf(counter, 3) = number(i, j);
%         % Add the fraction of data that each bin contains
%         sortdf(counter, 4) = number(i, j) / sum(number(:));
%         % increase counter
%         counter = counter + 1;
%     end % for 2
% end %for 1

%%
% Convert sortdf array into a nice looking table
dfsort = array2table(sortdf, 'VariableNames',...
                    {'FSC', 'SSC', 'count', 'fraction'});
                
[dfsort, index] = sortrows(dfsort, 'fraction', 'descend');
dfsort.index = index;

%%
% Add column with the cumulative fraction
dfsort.cumfrac = cumsum(dfsort.fraction);

%%
% Let's find the inter-bin distance
xbinDist = diff(fscCenter);
xbinDist = xbinDist(1);
ybinDist = diff(sscCenter);
ybinDist = ybinDist(1);

%%
% Let's keep the bins that have Victoria% or less of the data
percent = 0.3;

% Generate boolean array to know which bins to keep
binsToKeep = dfsort.cumfrac <= percent;

% Keep only the bins that satisfied Victorias condition
dfKept = dfsort(binsToKeep, :);

%%
% Now we will loop through each of the bins that we kept and we will find
% which data points fall inside these bins

% Initialize an array to keep track of which data points we will keep
idx = zeros([height(df), 1]);

% generate a for loop to loop through each of the bins
for i=1:height(dfKept)
    % Generate the box boundaries
    xbin = [dfKept(i, :).FSC - xbinDist / 2, dfKept(i, :).FSC + xbinDist / 2];
    ybin = [dfKept(i, :).SSC - ybinDist / 2, dfKept(i, :).SSC + ybinDist / 2];
    % Find which data points are inside the box
    [inBox, on] = inpolygon(df.logFSC, df.logSSC, xbin, ybin);
    % update the boolean array to know which data passed the filter
    idx = idx | inBox;
end %for

%%

gatedf = unsupervised_gating(df, 0.01, [500 500], 'FSC_H', 'SSC_H', true);

scatplot(df.logFSC, df.logSSC)
hold on
scatter(log(gatedf.FSC_H), log(gatedf.SSC_H), 'r')
% set(gca, 'xscale', 'log', 'yscale', 'log')
xlabel('Front scattering (a.u.)')
ylabel('Side scattering (a.u.)')
hold off


