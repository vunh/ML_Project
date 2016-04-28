% This function is for computing medians and Lab histograms of superpixels
% in an image

function [median_list, histogram_list] = getLabInformation (spmap, lab_img)

nbins = 32;

max_sp_ids = length(unique(spmap));
median_list = zeros(max_sp_ids, 3);
histogram_list = zeros(max_sp_ids, nbins, 3);
l_arr = lab_img(:,:,1);  l_arr = l_arr(:);
a_arr = lab_img(:,:,2);  a_arr = a_arr(:);
b_arr = lab_img(:,:,3);  b_arr = b_arr(:);

for i = 1:max_sp_ids
    idx = find(spmap(:) == i);
    median_list(i,:) = [median(l_arr(idx)), median(a_arr(idx)), median(b_arr(idx))];
    [N_l,~] = histcounts(l_arr(idx),nbins);
    [N_a,~] = histcounts(a_arr(idx),nbins);
    [N_b,~] = histcounts(b_arr(idx),nbins);
    histogram_list(i, :, 1) = N_l;
    histogram_list(i, :, 2) = N_a;
    histogram_list(i, :, 3) = N_b;
end

end