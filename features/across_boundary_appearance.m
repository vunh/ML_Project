% This function computes the boundary-based similarity between the
% superpixels in the same frame
% Should put contour map for edgemap input

function sim = across_boundary_appearance(spmap, edgemap,option)

% Param
if (nargin > 2)
    g = option.g;
else
    g = 0.08;
end
%g = 1;

aff = spAffinities(spmap, edgemap);

sim = exp(-aff*g);
%sim = aff;

end