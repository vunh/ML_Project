function main_test_image_segmentation()

addpath(genpath(pwd));
addpath(genpath('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/Ncut_9'));

nbCluster = 200;

% Load image and superpixel map of the video
%im = imread('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std/girl/00001.png');
dataset_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std';
load('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_SegTrack_v2/spinfo_girl.mat');
load('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/working_dir/graph_topo_girl.mat');
opticalflow_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/opticalflow_SegTrack_v2';
op_flow = load(fullfile(opticalflow_dir, 'girl.mat')); op_flow = op_flow.o_flow;
frames = load_frames(fullfile(dataset_dir, 'girl'), 'png');
superpixel_map = sp(20).spmap;
ucm_map = sp(20).ucm;
edge_map = sp(20).edge;

% Build graph
single_aff_aba = across_boundary_appearance(uint16(superpixel_map), edge_map);

% Load topology


[gr_aba, aff_aba] = addFeature_AccrossBoundaryAppearance ({sp.spmap}, {sp.edge}, 0, graph, intra_graph);
[sta_graph, sta_feature_intra_sim, sta_feature_intra_hist, sta_feature_inter_sim, sta_feature_inter_hist] = addFeature_SpatioTemporalAppearance ...
    (frames, {sp.spmap}, 0, graph, intra_graph, inter_graph);
%[stm_graph, stm_feature_intra_sim, stm_feature_intra_hist, stm_feature_inter_sim, stm_feature_inter_hist] = addFeature_SpatioTemporalMotion ...
%        ({sp.spmap}, 0, graph, intra_graph, inter_graph, op_flow);

% Partition
%final_graph = 10*aff_aba{20} + sta_feature_intra_sim{20} + sta_feature_intra_hist{20};
%final_graph = aff_aba{20} + sta_feature_intra_sim{20};
%final_graph = sta_feature_intra_sim{20};
final_graph = aff_aba{20};
%final_graph = 10*aff_aba{20} + sta_feature_intra_sim{20} + sta_feature_intra_hist{20};
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(final_graph,nbCluster);
%[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(single_aff_aba,nbCluster);


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

function frames = load_frames(video_dir, ext)

frames = [];

files = dir(fullfile(video_dir, ['*' ext]));
files = {files.name};
for i = 1:length(files)
    frame_path = fullfile(video_dir, files{i});
    frames(:,:,:,i) = rgb2lab(imread(frame_path));
end


end


