function [ref_memb, vectors_base_px, normals, Iproj] = Ref_memb_Normal_vecs(I, nPoints, smooth_filter_width)
%% Calculate Reference Membrane and Normal vectors
%
% Arguments:
%   I := full image matrix [y,x,t] of full image projection [y,x], or image
%       projection 
%   nPoints := number of points of reference membrane/reference vectors
%   smooth_filter_width := size of filter to smooth reference membrane
%
% Outputs:
%   ref_memb := coordinates of reference membrane [x,y], normals, Iproj
%   vectors_base_px := coordinates of the base of normal vectors [x,y].
%       These points are located in the middle of each pair of points of ref_memb 
%   normals := versors [x,y] normal to the reference membrane 
%   Iproj := median projection of I
%
%% Reference Membrane by Projection
step = 1;
plot_all = 0;
plot_end = 0;

size_I = size(I);

if size_I > 2
    Iproj = squeeze(median(I,3));
else
    Iproj = I;
end
    
ref_memb = calc_reference_membrane(Iproj,step, smooth_filter_width, nPoints, plot_all, plot_end);

%% Normal Vectors
[vectors_base_px, normals] = calculate_normals(ref_memb);


