%% Calculate Normal Vectors
function [vector_base, normals] = calculate_normals(ref_memb)

ref_memb_ahead = ref_memb(2:end, :);
ref_memb_ahead(end + 1, :) = ref_memb(1, :);
memb_vectors = ref_memb_ahead - ref_memb;

normals_y = ones(size(ref_memb(:,2)));
normals_x = - memb_vectors(:,2)./memb_vectors(:,1);
normals = [normals_x normals_y];
normals = normals ./ calc_norms(normals);
normals(isnan(normals(:,1)), 1) = 1;
cross_value = cross([normals zeros(size(normals(:,1)))], [memb_vectors zeros(size(normals(:,1)))]);
normals(cross_value(:,3)<0, :) = - normals(cross_value(:,3)<0, :);
normals(end,:) = [];
vector_base = (ref_memb_ahead - ref_memb)./2 + ref_memb;
vector_base(end,:) = [];

end
