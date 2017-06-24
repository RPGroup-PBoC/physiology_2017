function rename_files(datadir, pattern, renameTemplate, disp)
% This function renames the files contain in "dir" that have "pattern" as
% part of their name file. The new names must be saved in an excel file
% arranged in the same order as the data was taken.
% Parameters
% ----------
% datadir : str.
%     String pointing at the directory containing the fcs files that will be
%     renamed
% pattern : str.
%     String containing a pattern to be found in the files. This can be for 
%     example the date or the run.
%     Example : '2017-06-20', '2017-06-22*r1*'
% renameTemplate : str.
%     String pointing at an excel file that contains the new names for the
%     files.
% disp : bool.
%     Boolean indicating if the process should print the files that are
%     being renamed as they are processed.

% Read the csv file with the right names.
[num,fileRename,raw] = xlsread(renameTemplate);

% List the files to be renamed.
files = dir([datadir pattern]);

% Loop through files renaming on each instance the file
for i=1:length(files)
    % Point at the old file directory
    oldFile = strcat(datadir, files(i).name);
    % Point at the new file directory
    newFile = strcat(datadir, fileRename(i));
    % Convert to a char data tipe (super annoying matlab thing)
    newFile = char(newFile);
    % Move file to it's new name
    movefile(oldFile, newFile);
    
    % Check if the user wants the output to be print
    if disp  
        [files(i).name '-->' fileRename(i)]
    end %if
end % function