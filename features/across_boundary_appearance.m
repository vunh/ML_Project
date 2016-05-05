% This function computes the boundary-based similarity between the
% superpixels in the same frame
% Should put contour map for edgemap input

function sim = across_boundary_appearance(spmap, edgemap)

aff = spAffinities(spmap, edgemap);

sim = exp(-aff);

end