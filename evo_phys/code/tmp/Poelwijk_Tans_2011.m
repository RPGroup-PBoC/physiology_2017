% Read Sandar tans data
df = readtable('../data/Poelwijk_Tans_2011.csv');


% Extract the unique sucrose concentrations
sucrose = unique(df.sucrose_percent);

% Initialize plot to show data points
figure()
hold on
% Loop through concentrations plotting data
for i=1:length(sucrose)
    data = df(df.sucrose_percent==sucrose(i), :);
    plot(data.E_au, data.doubling_per_hour, 'o')
end %for

set(gca, 'xscale', 'log');
hold off
