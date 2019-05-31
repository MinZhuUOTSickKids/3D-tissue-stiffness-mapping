function [fitresult, gof1] = createFit(time, displacement,const1,const2)
%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( time, displacement );

% Set up fittype and options.
eqn = @(a,b,x) ((1/a)*(1-(const1-a)/const1*exp(-x*(const1-a)*a/const1/b))+x/const2);
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Robust = 'Bisquare';
opts.Lower = [0,0];
opts.Upper = [const1,;];
% Fit model to data.
[fitresult, gof1] = fit( xData, yData, eqn, opts );

% Plot fit with data.
figure()
h = plot( fitresult, xData, yData );
title(['SLSwDP fitting result ' ', R^2=' num2str(gof1.rsquare)])
set(gca,'FontSize',15);
xlabel('Time (s)','FontSize',15);
ylabel('Displacement (microns)','FontSize',15);
grid on


