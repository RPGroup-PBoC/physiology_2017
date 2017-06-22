% In this script we will generate an automatic gating procedure by fitting
% a 2D gaussian function to the front and side scattering comming from the
% flow cytometer

% First thing is to point at the directory where the CSV data files exist
csvDir = '../data/20170620_competition/csv/';

% Next we are going to list all the files in that directory
files = dir([csvDir '*csv']);

% Now let's read one file for the example.
df = readtable([csvDir, files(1).name]);
df(1:3, :)

%%
% Let's look at a scatter plot of the data
% https://www.mathworks.com/matlabcentral/fileexchange/8577-scatplot

scatplot(log(df.FSC_H(:)), log(df.SSC_H(:)), 'squares')
xlabel('front scattering (a.u.)')
xlabel('side scattering (a.u.)')
%%
% We will now fit a 2D Gaussian to the log of the data data. 
% For this we will hack the function fitgmdist.

% First we extract the parameters we will use for the fit and convert them
% into an array.
fitData = df(:, {'FSC_H', 'SSC_H'});
fitData = table2array(fitData);

% For the fit we will actually use the log of the data
GaussFit = fitgmdist(log(fitData), 1);

% Extract the mean and covariance of the fit distribution
mu = GaussFit.mu;
Sigma = GaussFit.Sigma;

%%

% Define array x as log(fitData) - mu
x = log(fitData) - mu;

% Initialize array to save the value of the statistic
statistic = zeros([1, length(x)]);

% Compute the statistic for all data using a for loop
for i=1:length(x)
    statistic(i) = x(i, :) * inv(Sigma) * x(i, :)';
end %for

%%

thresh = chi2inv(0.4, 2);

idx = statistic <= thresh;

fitDataClean = fitData(idx, :);

%%
scatplot(log(fitDataClean(:,1)), log(fitDataClean(:, 2)), 'squares')
xlabel('front scattering (a.u.)')
ylabel('side scattering (a.u.)')


