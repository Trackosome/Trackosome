%% Normalize Membrane Coords (Subtract Centroid)

function [centered_frame, centered_memb_coords] = membrane_Translaction(I_frame, memb_coords, centroid, ref_centroid)

transl_vec = [ round( ref_centroid(1) - centroid(1) ), round(ref_centroid(2) - centroid(2) )];

centered_frame = imtranslate(I_frame, transl_vec);   
centered_memb_coords = memb_coords - centroid + ref_centroid;

end