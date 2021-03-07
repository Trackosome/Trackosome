function [amp, mean_value, sigma, foundCoords] = fitGauss(intProfile, lims)

foundCoords = 1;
amp = 0;
mean_value = 0;

y = double(intProfile);

[lines, ~] = size(y);
x = find(y~=0);

% sigma = std(y(x))/10;
sigma = length(x)/2;
u = mean(x);
ampt = max(y(x));

minFactor = 0.1;
maxFactor = 10;

lower = [ampt*minFactor , u*minFactor , 0 ];
upper = [ampt*maxFactor, u*maxFactor , sigma*maxFactor ];
startPoint = [ampt, u, sigma];

fit_opt = fitoptions( 'Method', 'NonlinearLeastSquares', 'Algorithm', 'Trust-Region', 'Lower', lower, 'Upper', upper, 'StartPoint',  startPoint);

fit_fun = fittype( 'a*exp(-(x - b).^2/(2*c^2))', 'independent', 'x', 'options', fit_opt);

if lines == 1
    try
    [fit_obj, ~] = fit( x', y(x)', fit_fun);
    catch
        foundCoords = 0;
        return
    end
else
    try
    [fit_obj, ~] = fit( x, y(x), fit_fun);
    catch
       foundCoords = 0;
       return
    end
end

mean_value = fit_obj.b;

if mean_value < lims(1)
    mean_value = lims(1);
elseif mean_value > lims(2)
    mean_value = lims(2);
end

amp = fit_obj.a;
sigma = fit_obj.c;


% figure
% plot(y), hold on,
% plot(x,a*exp(-(x - b).^2/(2*c^2)), 'k'),
% plot(b, y(round(b)), 'k*')


