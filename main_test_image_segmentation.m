function main_test_image_segmentation()

addpath(genpath(pwd));
addpath(genpath('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/Ncut_9'));

nbCluster = 50;

% Load image and superpixel map of the video
%im = imread('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std/girl/00001.png');
load('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_SegTrack_v2/spinfo_girl.mat');
superpixel_map = sp(1).spmap;
ucm_map = sp(1).ucm;

% Build graph
aff_aba = across_boundary_appearance(uint16(superpixel_map), ucm_map);

% Partition
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(aff_aba,nbCluster);


% Plot result
new_img = zeros(size(superpixel_map));
nSP = max(superpixel_map(:));
for i = 1:nSP
    cluster_id = find(NcutDiscrete(i,:));
    new_img(superpixel_map == i) = cluster_id;
end

imagesc(new_img);
colormap parula;


end