function [metric] = calc_profile_metric(intProfile, rCentrosome, axis)

localMinStrenght = 20;

% Limits of the profile around the hypothetical centrosome:
[peak_amp, peak_idx] = max(intProfile);
inds = find(intProfile>0);
leftBorder  = max(inds(1), peak_idx - round(rCentrosome));
rightBorder = min(inds(end), peak_idx + round(rCentrosome));
ampLeftBorder  = intProfile(leftBorder);
ampRightBorder = intProfile(rightBorder);

localMinFactor = 0;
 
% Account for local maxs/mins in the intensity profiles
if axis == 'Z'
    
    
    diffLeft = diff(intProfile(leftBorder:peak_idx));
    diffRight = diff(intProfile(peak_idx:rightBorder));    
    
    border_amp = peak_amp - min(ampLeftBorder, ampRightBorder);    
    
    changeDerivLeft = (sum((diffLeft(diffLeft<0))));    
    if changeDerivLeft < 0
        localMinFactor = abs(changeDerivLeft)/border_amp;
    end
    
    changeDerivRight = sum(diffRight(diffRight>0));
    if changeDerivRight > 0
        localMinFactor = changeDerivRight/border_amp + localMinFactor;
    end
   
    
end

% Calc metric
metric = (peak_amp-ampLeftBorder )*(peak_amp-ampRightBorder )/peak_amp^2 * (1 - localMinFactor)^localMinStrenght;
% 
% figure(666)
% if axis == 'X' 
%     subplot 131
% elseif axis == 'Y'
%     subplot 132
% else
%     subplot 133
% end
% plot(intProfile), hold on
% plot(peak_idx, peak_amp, 'ro'), hold on
% plot(leftBorder,intProfile(leftBorder), 'b*')
% plot(rightBorder, intProfile(rightBorder), 'b*')
% title([axis ': ' num2str(metric)])

end

