% Date : 20170620
% Experiment : O2 lacI titration on flow cytometry
date = '20170620';
run = 'r1';
operator = 'O2';

% Add path to functions folder
addpath('../../functions/')
% Indicate directory where data lives
dataDir = '../../../data/csv/';
% Indicate pattern to find in directory
filePattern = [date '_' run '_' operator '*csv'];
% List the files
files = dir([dataDir filePattern]);

%%

% Define fraction of data to keep
frac = 0.1;

file = [files(1).folder '/' files(1).name];
% read CSV file
df = readtable(file);
% gate by front and side scattering
gatedf = unsupervised_gating(df, frac, [500 500], 'FSC_H', 'SSC_H', true);
