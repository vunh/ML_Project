% This function is for computing medians and motion histograms of superpixels
% in an image

function [median_list, histogram_list] = getMotionInformation (spmap, opticalflow)

nbins = 10;
motion_range = [-10, 10];
bin_motion = motion_range(1):(motion_range(2)-motion_range(1))/nbins:motion_range(2);

max_sp_ids = length(unique(spmap));
median_list = zeros(max_sp_ids, 2);
histogram_list = zeros(max_sp_ids, nbins, 2);

of_u = opticalflow.u; of_u = of_u(:);
of_v = opticalflow.v; of_v = of_v(:);

for i = 1:max_sp_ids
    idx = find(spmap(:) == i);
    median_list(i,:) = [median(of_u(idx)), median(of_v(idx))];
    [N_u,~] = histcounts(of_u(idx), bin_motion);
    [N_v,~] = histcounts(of_v(idx), bin_motion);
    histogram_list(i, :, 1) = N_u;
    histogram_list(i, :, 2) = N_v;
end

end