function main_test_image_segmentation()

option_aba.g = 0.08;

option_sta.nbinsL = 16;
option_sta.nbinsA = 4;
option_sta.nbinsB = 4;
option_sta.L_range = [0, 1.01];
option_sta.a_range = [0, 1.01];
option_sta.b_range = [0, 1.01];
option_sta.lambda_sta = 40;
option_sta.lambda_sta_2 = 70;
%option_sta.g1 = 1;
%option_sta.g2 = 0.5;

%option_stm.nbins = 20;
%option_stm.motion_range = [-10, 10];
%option_stm.lambda_sta = 20;
option_stm.lambda_sta = 20;
option_stm.lambda_sta_2 = 50;
%option_stm.g1 = 1;
%option_stm.g1 = 4;
%option_stm.g2 = 0.5;
option_stm.nbins_ang = 8;
option_stm.nbins_mag = 10;
option_stm.angle_range = [-pi, pi];
option_stm.magnitude_range = [0, 10];

addpath(genpath(pwd));
addpath('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/visualization');
addpath(genpath('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/Ncut_9'));

nbCluster = 20;

% Load image and superpixel map of the video
%im = imread('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std/girl/00001.png');
dataset_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std';
load('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_SegTrack_v2/spinfo_girl.mat');
load('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/working_dir/graph_topo_girl.mat');
opticalflow_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/opticalflow_SegTrack_v2';
op_flow = load(fullfile(opticalflow_dir, 'girl.mat')); op_flow = op_flow.o_flow;
frames = load_frames(fullfile(dataset_dir, 'girl'), 'png');
superpixel_map = sp(1).spmap;
ucm_map = sp(1).ucm;
edge_map = sp(1).edge;

% Build graph
single_aff_aba = across_boundary_appearance(uint16(superpixel_map), edge_map,option_aba);

% Load topology


[gr_aba, aff_aba] = addFeature_AccrossBoundaryAppearance ({sp.spmap}, {sp.edge}, 0, graph, intra_graph, option_aba);
[sta_graph, sta_feature_intra_sim, sta_feature_intra_hist, sta_feature_inter_sim, sta_feature_inter_hist] = addFeature_SpatioTemporalAppearance ...
    (frames, {sp.spmap}, 0, graph, intra_graph, inter_graph, option_sta);
[stm_graph, stm_feature_intra_sim, stm_feature_intra_hist, stm_feature_inter_sim, stm_feature_inter_hist] = addFeature_SpatioTemporalMotion ...
        ({sp.spmap}, 0, graph, intra_graph, inter_graph, op_flow, option_stm);

% Partition
%final_graph = 5*aff_aba{1} + 3*sta_feature_intra_sim{1} + sta_feature_intra_hist{1} + 3*stm_feature_intra_sim{1} + stm_feature_intra_hist{1};
%final_graph = aff_aba{1} + sta_feature_intra_sim{1};
%final_graph = sta_feature_intra_sim{1};
%final_graph = stm_feature_intra_hist{1};
%final_graph = 10*aff_aba{1} + sta_feature_intra_sim{1} + sta_feature_intra_hist{1};
final_graph= aff_aba{1};
%display(stm_feature_intra_hist,1);
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(final_graph,nbCluster);
%[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(single_aff_aba,nbCluster);


% Plot result
new_img = zeros(size(superpixel_map));
nSP = max(superpixel_map(:));
for i = 1:nSP
    cluster_id = find(NcutDiscrete(i,:));
    new_img(superpixel_map == i) = cluster_id;
end
figure;
a=gen_cl_from_spmap(new_img,[]);
imshow(uint8(a));
colormap parula;


end

function frames = load_frames(video_dir, ext)

frames = [];

files = dir(fullfile(video_dir, ['*' ext]));
files = {files.name};
for i = 1:length(files)
    frame_path = fullfile(video_dir, files{i});
    frames(:,:,:,i) = rgb2hsv(imread(frame_path));
end


end

function display(data,i)

figure;
a = full(data{i});
a = a(a~=0);
histogram(a);

end


