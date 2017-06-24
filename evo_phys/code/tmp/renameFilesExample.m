% Code to rename the flow-cytometry files given a CSV files that contains
% the desired names.

% 1) Read the csv file with the right names.
[num,fileRename,raw] = xlsread('../data/20170620_competition/filename.xlsx');
%%
% Define data directory containing fcs files
fcsDir = '../data/20170620_competition/fcs/';

% List the files that I want to rename
files = dir([fcsDir '*fcs']);

%%
% Loop through files renaming on each instance the file

for i=1:length(files)
    % Point at the old file directory
    oldFile = strcat(fcsDir, files(i).name);
    % Point at the new file directory
    newFile = strcat(fcsDir, fileRename(i));
    % Convert to a char data tipe (super annoying matlab thing)
    newFile = char(newFile)
    % Move file to it's new name
    movefile(oldFile, newFile);
    [oldFile '-->' newFile]
end %for

%%
% List again the files with their new name
files = dir([fcsDir '*fcs']);

% Set example file to read
fileExample = char(strcat(fcsDir, files(5).name));

% Read fcs file
% http://www.mathworks.com/matlabcentral/fileexchange/9608-fcs-data-reader
[rawData, metaData, fcsdatscaled] = fca_readfcs(fileExample);
%%
% Let's explore what these ouputs are

% class(rawData)
% size(rawData)

% class(metaData)
% metaData.par
% metaData.par.name

%%
% Let's extract the parameter names
% We will use a data stucture known as cell arrays
param = {metaData.par.name};

% Now we will generate a table where the headers are each of these
% parameter names
% dfFCS = array2table(rawData, 'VariableNames', param);

% There's an error! It is hard to know why matlab didn't like our variable
% names, but my first guess is that for some reason it doesn't like the
% dash in between the variables. We can get around this by replacing it by
% an underscore.
param = strrep(param, '-', '_');

% Let's try it again.
dfFCS = array2table(rawData, 'VariableNames', param);

dfFCS(1:3, :)

%%
% Let's save this into our CSV file to avoid repeating this process.

% first we define the directory where I want to save my CSV files
csvDir = '../data/20170620_competition/csv/';

% Then I generate the equivalent name of the file but with .csv rather than
% .fcs
fileCSV = metaData.filename;
% replace fcs for csv
fileCSV = strrep(fileCSV, 'fcs', 'csv');

% Write the file into the csv/ directory with the new name
filepath = strcat(csvDir, fileCSV);
writetable(dfFCS, filepath);

%%
% Let's now put this into a for loop to re-write all FCS files into CSV.
%

for i=1:length(files)
    % Set example file to read
    fileFCS = char(strcat(fcsDir, files(i).name));
    % Read fcs file
    [rawData, metaData, fcsdatscaled] = fca_readfcs(fileFCS);
    % Extract name of columns
    param = {metaData.par.name};
    % Replace dash '-' with underscore '_'
    param = strrep(param, '-', '_');
    % Generate table with these titles
    df = array2table(rawData, 'VariableNames', param);
    % Define file of csv file
    fileCSV = strrep(files(i).name, 'fcs', 'csv');
    % Define the full path for the file
    filepath = strcat(csvDir, fileCSV);
    % Write down the csv files
    writetable(df, filepath);
    fileCSV
end %for

