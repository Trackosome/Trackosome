function ref_memb_px = calc_reference_membrane(Iproj, masks, step, filterWindow, nPoints, plot_all, plot_end)
%% Calculates reference membrane 


frame_size = size(Iproj);

% % Segmentation:
masks_mat = cat(3, masks{:});
mask = any(masks_mat, 3);
membrane_mask = Calc_Membrane_Mask( Iproj, mask, plot_all );

%% Extract Coords of Reference Membrane:
if  plot_all || plot_end
    figure
end
[XY_borders] =  Extract_Profiles( membrane_mask, step, plot_all, plot_end);

if  plot_all || plot_end
    figure
end

ref_memb_raw = Extract_Membrane_Coords_NEO(Iproj, XY_borders, filterWindow, plot_all, plot_end);
ref_memb_px = interp_equal_space(ref_memb_raw, nPoints + 1);

if   plot_end
    figure
    imagesc(Iproj)
    colormap('jet')
    hold on
    plot(ref_memb_px(:,1), ref_memb_px(:,2), 'color', [1 1 1], 'marker', '.', 'markersize', 10)
    axis equal
end

end

