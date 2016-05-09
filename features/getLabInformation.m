% This function is for computing medians and Lab histograms of superpixels
% in an image

function [median_list, histogram_list] = getLabInformation (spmap, lab_img)

nbins = 10;
L_range = [0, 100];
a_range = [-127, 128];
b_range = [-127, 128];

bin_L = L_range(1):(L_range(2)-L_range(1))/nbins:L_range(2);
bin_a = a_range(1):(a_range(2)-a_range(1))/nbins:a_range(2);
bin_b = b_range(1):(b_range(2)-b_range(1))/nbins:b_range(2);

max_sp_ids = length(unique(spmap));
median_list = zeros(max_sp_ids, 3);
histogram_list = zeros(max_sp_ids, nbins, 3);
l_arr = lab_img(:,:,1);  l_arr = l_arr(:);
a_arr = lab_img(:,:,2);  a_arr = a_arr(:);
b_arr = lab_img(:,:,3);  b_arr = b_arr(:);

for i = 1:max_sp_ids
    idx = find(spmap(:) == i);
    median_list(i,:) = [median(l_arr(idx)), median(a_arr(idx)), median(b_arr(idx))];
    [N_l,~] = histcounts(l_arr(idx),bin_L);
    [N_a,~] = histcounts(a_arr(idx),bin_a);
    [N_b,~] = histcounts(b_arr(idx),bin_b);
    histogram_list(i, :, 1) = N_l;
    histogram_list(i, :, 2) = N_a;
    histogram_list(i, :, 3) = N_b;
end

end