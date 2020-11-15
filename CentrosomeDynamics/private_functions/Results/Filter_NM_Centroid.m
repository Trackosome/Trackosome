%% Filter Nuclear Membrane Centroid
function [filtered_NM_centroid] = Filter_NM_Centroid(NM_centroid_trim, window, toPlot)

filtered_NM_centroid = zeros(size(NM_centroid_trim));
filtered_NM_centroid(:,1) = movmean(NM_centroid_trim(:,1),window);
filtered_NM_centroid(:,2) = movmean(NM_centroid_trim(:,2),window);
filtered_NM_centroid(:,3) = movmean(NM_centroid_trim(:,3),window);

% Plot Centrosome, filtered Centroid Trajectory and Nuclear Membrane
if toPlot
    sz = 15;
    
    c = linspace(1,10,length(NM_centroid_trim(1,:)));
    
    figure
    plot3(NM_centroid_trim(1,1), NM_centroid_trim(2,1), NM_centroid_trim(3,1),'g*','MarkerSize',8), hold on
    plot3(NM_centroid_trim(1,:), NM_centroid_trim(2,:), NM_centroid_trim(3,:),'k')
    plot3(filtered_NM_centroid(1,:), filtered_NM_centroid(2,:), filtered_NM_centroid(3,:))
    scatter3(filtered_NM_centroid(1,:), filtered_NM_centroid(2,:), filtered_NM_centroid(3,:), sz,c,'filled');
    
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    title('Centroid Trajectory: Filtered VS Raw')
    drawnow
end
end