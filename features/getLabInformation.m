% This function is for computing medians and Lab histograms of superpixels
% in an image

function [median_list, histogram_list] = getLabInformation (spmap, lab_img, option)

nbinsL = option.nbinsL;
nbinsA = option.nbinsA;
nbinsB = option.nbinsB;
% L_range = [0, 100];
% a_range = [-127, 128];
% b_range = [-127, 128];

%lab_img = rgb2hsv(lab2rgb(lab_img));
L_range = option.L_range;
a_range = option.a_range;
b_range = option.b_range;

bin_L = L_range(1):(L_range(2)-L_range(1))/nbinsL:L_range(2);
bin_a = a_range(1):(a_range(2)-a_range(1))/nbinsA:a_range(2);
bin_b = b_range(1):(b_range(2)-b_range(1))/nbinsB:b_range(2);

max_sp_ids = length(unique(spmap));
median_list = zeros(max_sp_ids, 3);
%histogram_list = zeros(max_sp_ids, nbins, 3);
histogram_list = zeros(max_sp_ids, nbinsL + nbinsA + nbinsB);
l_arr = lab_img(:,:,1);  l_arr = l_arr(:);
a_arr = lab_img(:,:,2);  a_arr = a_arr(:);
b_arr = lab_img(:,:,3);  b_arr = b_arr(:);

for i = 1:max_sp_ids
    idx = find(spmap(:) == i);
    median_list(i,:) = [median(l_arr(idx)), median(a_arr(idx)), median(b_arr(idx))];
    [N_l,~] = histcounts(l_arr(idx),bin_L);
    [N_a,~] = histcounts(a_arr(idx),bin_a);
    [N_b,~] = histcounts(b_arr(idx),bin_b);
%     histogram_list(i, :, 1) = N_l;
%     histogram_list(i, :, 2) = N_a;
%     histogram_list(i, :, 3) = N_b;
    histogram_list(i, :) = [N_l, N_a, N_b];
end

temp = sum(histogram_list,2);
temp = repmat(temp, 1, nbinsL + nbinsA + nbinsB);
histogram_list = histogram_list ./ temp;


% add for intensity
% max_sp_ids = length(unique(spmap));
% median_list = zeros(max_sp_ids, 3);
% histogram_list = zeros(max_sp_ids, nbins, 1);
% 
% G_range = [0, 255];
% bin_G = G_range(1):(G_range(2)-G_range(1))/nbins:G_range(2);
% 
% rgb_img = lab2rgb(lab_img);
% gray_img = rgb2gray(rgb_img);
% %gray_img = rgb_img(:,:,2);
% gray_arr = gray_img(:);
% for i = 1:max_sp_ids
%     idx = find(spmap == i);
%     median_list(i,:) = median(gray_arr(idx));
%     [N_g,~] = histcounts(gray_arr(idx),bin_G);
%     histogram_list(i, :, 1) = N_g;
% end
% 
% % median_list = median_list ./ 255;
% % new_img = zeros(size(spmap));
% % for i = 1:max_sp_ids
% %     new_img(spmap == i) = median_list(i, 1);
% % end
% % 
% % a = 3;

a=3;
end