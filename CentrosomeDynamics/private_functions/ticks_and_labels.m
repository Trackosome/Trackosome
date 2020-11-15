function ticks_and_labels(axes, px2um)
%% Set ticks and labels of figures
% Domingos Leite de Castro, domingos.castro@i3s.up.pt
% Paulo de Castro Aguiar, pauloaguiar@ineb.up.pt

axis(axes, 'equal')
xticks_vals = xticklabels(axes);
yticks_vals = yticklabels(axes);
xticklabels(axes, round(str2double(xticks_vals) * px2um));
yticklabels(axes, round(str2double(yticks_vals) * px2um));
ylabel(axes, 'um')
xlabel(axes, 'um')