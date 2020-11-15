
function memb_frame_nPoints = interp_equal_space(memb_frame, nPoints)

stepLengths = sqrt(sum(diff(memb_frame,[],1).^2,2));
stepLengths = [0; stepLengths];
cumulativeLen = cumsum(stepLengths);
finalStepLocs = linspace(0,cumulativeLen(end), nPoints);
[cumulativeLen, index] = unique(cumulativeLen);
memb_frame_nPoints = interp1(cumulativeLen, memb_frame(index, :), finalStepLocs);

end