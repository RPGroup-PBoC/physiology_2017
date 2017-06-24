function fcs2csv(fcsDir, csvDir, pattern, disp)
% Converts fcs files contained in 'fcsDir; into csv saving them into 
% csvDir. The files that are converted into csv must contain in their
% filename 'pattern'.
% Parameters
% ----------
% fcsDir : str.
%     String pointing at the directory in which the fcs files that will be
%     converted into csv live.
% csvDir : str.
%     String pointing at where do the csv files should be saved.
% pattern : str.
%     String with a pattern common to all the files that will be converted
%     from fsc into csv.
% disp : bool.
%     Boolean indicating if the process should print the files that are
%     being converted as they are processed.

    % List again the files to be converted into csv
    files = dir([fcsDir pattern '*fcs']);

    % Loop through files to convert them into csv.
    for i=1:length(files)
        % Set file name to be read.
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

        % Check if the user wants the output to be print
        if disp  
            [fileFCS ' --> ' fileCSV]
        end %if
    end %for
end %function