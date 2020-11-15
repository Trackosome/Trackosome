function  metric = calc_profile_metric2(intProfile, rCentrosome, axis)

% Limits of the profile around the hypothetical centrosome:
[peak_amp, peak_idx] = max(intProfile);
inds = find(intProfile>0);

if ~isempty(inds)
leftBorder  = max(inds(1), peak_idx - round(rCentrosome));
rightBorder = min(inds(end), peak_idx + round(rCentrosome));
ampLeftBorder  = intProfile(leftBorder);
ampRightBorder = intProfile(rightBorder);

m = (ampRightBorder - ampLeftBorder) / (rightBorder - leftBorder);
b = ampLeftBorder - m * leftBorder;
base = [leftBorder:rightBorder] .* m + b;

profileInBorders = intProfile(leftBorder:rightBorder);

if size(base) == size(profileInBorders)
area = sum(profileInBorders - base);
else
area = sum(profileInBorders' - base);
end

metric = area/sum(intProfile);


% % figure(666)
% % if axis == 'X' 
% %     subplot 131
% % elseif axis == 'Y'
% %     subplot 132
% % else
% %     subplot 133
% % end
% % plot(intProfile), hold on
% % plot(peak_idx, peak_amp, 'ro')
% % plot(leftBorder,intProfile(leftBorder), 'b*')
% % plot(rightBorder, intProfile(rightBorder), 'b*')
% % title([axis ': ' num2str(metric)])
% % plot(leftBorder:rightBorder, base, 'k.')

else
    
    msgbox('Error: Centrosome not found - make sure the Regions of Interest contain the Centrosomes')
    error('Error: Centrosome not found')
    
end

end