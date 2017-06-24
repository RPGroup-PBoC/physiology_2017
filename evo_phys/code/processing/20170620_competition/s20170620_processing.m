% Date : 20170620
% Experiment : O2 lacI titration on flow cytometry
date = '20170620';
operator = 'O1';

% Add path to functions folder
addpath('../../functions/')
% Indicate directory where data lives
dataDir = '../../../data/csv/';
% Indicate pattern to find in directory
filePattern = [date '_' operator '*csv'];
% List the files
files = dir([dataDir filePattern]);
%%

% Let's look at one of the files
df = readtable([dataDir files(1).name]);

% Adding log of front and side scattering columns
% Add log FSC and log SSC
df.logFSC = log(df.FSC_H);
df.logSSC = log(df.SSC_H);

% Gate on the front and side scattering
gatedf = unsupervised_gating(df, 0.10, [500 500], 'FSC_H', 'SSC_H', true);

%%
% Let's look at how the gating works for this data
scatplot(df.logFSC, df.logSSC)
hold on
scatter(gatedf.logFSC, gatedf.logSSC, 'r.')
xlabel('Front scattering (a.u.)')
ylabel('Side scattering (a.u.)')
hold off

%%
% Let's plot mCherry vs CFP
scatter(df.Y2_H, df.V2_H, '.')
hold on
scatter(gatedf.Y2_H, gatedf.V2_H, '.')
legend('raw data', 'gated data')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
xlabel('mCherry (a.u.)')
ylabel('CFP (a.u.)')
hold off












%%

% Define the fields listed in the
nameVariables = {'date' 'operator1' 'repressor1' 'color1' ...
                        'operator2' 'repressor2' 'color2' 'timepoint'}


% Define fraction of data to keep
frac = 0.4;

% array that will serve as data frame
dfSummary = cell2table(cell(length(files), 5), 'VariableNames',...
     {'date', 'run', 'operator', 'repressor', 'IPTG'});

% Initialize array to save mean YFP values
meanYFP = zeros([length(files), 1]);
for i=1:length(files)
    files(i).name
    % Split file name and add them
    splitFile = strsplit(regexprep(files(i).name, '.csv', ''), '_');
    dfSummary(i, {'date', 'run', 'operator', 'repressor', 'IPTG'}) = ...
        cell2table(splitFile);
    file = [files(i).folder '/' files(i).name];
    % read CSV file
    df = readtable(file);
    % gate by front and side scattering
    gatedf = unsupervised_gating(df, frac, [500 500], 'FSC_H', 'SSC_H',...
                                 true);
    meanYFP(i) = mean(gatedf.B1_H);
end %for

%%
% Add the mean YFP to the data frame
dfSummary.meanYFP = meanYFP;

% Extract the auto fluorescence from the mean YFP
meanAuto = table2array(dfSummary(strcmp(dfSummary.repressor, 'auto'),...
                                 'meanYFP'));

dfSummary.meanBgCorr = dfSummary.meanYFP - meanAuto(1);

%%
scatplot(df.logFSC, df.logSSC)
hold on
scatter(log(gatedf.FSC_H), log(gatedf.SSC_H), 'r.')
xlabel('Front scattering (a.u.)')
ylabel('Side scattering (a.u.)')
hold off