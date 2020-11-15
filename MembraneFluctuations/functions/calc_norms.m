function [norms] = calc_norms(V)

nVecs = length(V(:,1));
norms = zeros(nVecs, 1);

for i = 1: nVecs
    
   norms(i) = norm(V(i,:));
    
end