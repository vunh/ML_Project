function segment_video_nonregression(id)

% Config
nbCluster = 1000;
option_aba.g = 2;

option_sta.nbinsL = 16;
option_sta.nbinsA = 4;
option_sta.nbinsB = 4;
option_sta.L_range = [0, 1.01];
option_sta.a_range = [0, 1.01];
option_sta.b_range = [0, 1.01];
option_sta.lambda_sta = 0.03;
option_sta.lambda_sta_2 = 200;
%option_sta.g1 = 1;
%option_sta.g2 = 0.5;

%option_stm.nbins = 20;
%option_stm.motion_range = [-10, 10];
%option_stm.lambda_sta = 20;
option_stm.lambda_sta = 28;
option_stm.lambda_sta_2 = 50;
%option_stm.g1 = 1;
%option_stm.g1 = 4;
%option_stm.g2 = 0.5;
option_stm.nbins_ang = 8;
option_stm.nbins_mag = 10;
option_stm.angle_range = [-pi, pi];
option_stm.magnitude_range = [0, 10];



addpath(genpath(pwd));
addpath(genpath('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/Ncut_9'));

% Params
%video_name = 'birdfall';

% Auxiliary params
% ext = '.png';
% dataset_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std';
% superpixel_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_SegTrack_v2';
% opticalflow_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/opticalflow_SegTrack_v2';
% working_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/working_dir';
% svr_model_path = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/random_forest_model_vsb100/SVR_C10.000_G0.500.mat';

load('video_list.mat');
video_name = video_list(id).video_name;
ext = video_list(id).ext;
dataset_dir = video_list(id).dataset_dir;
superpixel_dir = video_list(id).superpixel_dir;
opticalflow_dir = video_list(id).opticalflow_dir;
working_dir = video_list(id).working_dir;
svr_model_path = video_list(id).svr_model_path;
result_dir = video_list(id).result_dir;



%% Load information
% Load frames
frames = load_frames(fullfile(dataset_dir, video_name), ext);
% Load superpixels
sp = load(fullfile(superpixel_dir, ['spinfo_' video_name])); sp = sp.sp;
spmap = {sp.spmap};
ucm = {sp.edge};
% Load optical flow
op_flow = load(fullfile(opticalflow_dir, video_name)); op_flow = op_flow.o_flow;
% Load SVR model
load(svr_model_path);


%% Build the affinity graph/map
% Find maximum number of superpixels in a frame
max_no_superpixel = 0;
for i = 1:length(spmap)
    curr_no_sp = length(unique(spmap{i}));
    if (max_no_superpixel < curr_no_sp)
        max_no_superpixel = curr_no_sp;
    end
end

% Total number of superpixels in this video, create global mapping from 
n_frame = length(spmap);
n_sp = 0;
global_spid_map = zeros(n_frame, max_no_superpixel);   % Global superpixel index mapping
for i = 1:length(sp)
    curr_no_sp = length(unique(spmap{i}));
    
    global_spid_map(i,1:curr_no_sp) = (n_sp+1):(n_sp+curr_no_sp);
    
    n_sp = n_sp + curr_no_sp;
end


% Build graph topology
graph_topo_file = fullfile(working_dir, ['graph_topo_' video_name '.mat']);
if (exist(graph_topo_file, 'file') == 2)
    load (graph_topo_file);
else
    disp('\nBuilding graph topo');
    [intra_graph, inter_graph] = graph_topo (spmap, global_spid_map, op_flow);
    save(graph_topo_file, 'intra_graph', 'inter_graph');
end

graph = sparse(n_sp, n_sp);


% Feed features to the graph
feature_file = fullfile(working_dir, ['features_' video_name '.mat']);
if (exist(feature_file, 'file') == 2)
    load (feature_file);
else
    disp('\nExtracting features');
    [gr_aba, aff_aba] = addFeature_AccrossBoundaryAppearance (spmap, ucm, global_spid_map, graph, intra_graph, option_aba);
    [sta_graph, sta_feature_intra_sim, sta_feature_intra_hist, sta_feature_inter_sim, sta_feature_inter_hist] = addFeature_SpatioTemporalAppearance ...
        (frames, spmap, global_spid_map, graph, intra_graph, inter_graph, option_sta);
    [stm_graph, stm_feature_intra_sim, stm_feature_intra_hist, stm_feature_inter_sim, stm_feature_inter_hist] = addFeature_SpatioTemporalMotion ...
        (spmap, global_spid_map, graph, intra_graph, inter_graph, op_flow, option_stm);
    save(feature_file, 'aff_aba', 'sta_feature_intra_sim', 'sta_feature_intra_hist', 'sta_feature_inter_sim', 'sta_feature_inter_hist',...
        'stm_feature_intra_sim', 'stm_feature_intra_hist', 'stm_feature_inter_sim', 'stm_feature_inter_hist');
end

fprintf('\nFinish computing features');
%graph = graph + aff_aba + aff_sta;


for iSubGraph = 1:(length(intra_graph)-1)
    fprintf('\nPredicting feature - intra graph - frame %d', iSubGraph);
    sub_aba = aff_aba{iSubGraph};
    sub_sta_sim = sta_feature_intra_sim{iSubGraph};
    sub_sta_hist = sta_feature_intra_hist{iSubGraph};
    sub_stm_sim = stm_feature_intra_sim{iSubGraph};
    sub_stm_hist = stm_feature_intra_hist{iSubGraph};
    set_of_features = [{sub_aba}, {sub_sta_sim}, {sub_sta_hist}, {sub_stm_sim}, {sub_stm_hist}];
    sub_graph = buildGraph(set_of_features, SVR_intra, iSubGraph, iSubGraph, global_spid_map);
    
    graph = Getcombinedsimilaritieswithmethod(graph,sub_graph);
end

for iSubGraph = 1:(length(inter_graph)-1)
    fprintf('\nPredicting feature - inter graph - frame %d', iSubGraph);
    sub_sta_sim = sta_feature_inter_sim{iSubGraph};
    sub_sta_hist = sta_feature_inter_hist{iSubGraph};
    sub_stm_sim = stm_feature_inter_sim{iSubGraph};
    sub_stm_hist = stm_feature_inter_hist{iSubGraph};
    set_of_features = [{sub_sta_sim}, {sub_sta_hist}, {sub_stm_sim}, {sub_stm_hist}];
    sub_graph = buildGraph(set_of_features, SVR_inter, iSubGraph, iSubGraph+1, global_spid_map);
    %graph = graph + sub_graph;
    graph = Getcombinedsimilaritieswithmethod(graph,sub_graph);
end

a = 3;
% Using NCut to partition the graph
tic;
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(graph,nbCluster);
toc;

segments = zeros(size(spmap{1}, 1), size(spmap{1}, 2), length(spmap) -1);
for iSP = 1:n_sp
    %fprintf('\n%d', iSP);
    if (iSP == 24856)
        b = 5;
    end
    cluster_id = find(NcutDiscrete(iSP,:));
    [frameID, localSPID] = find(global_spid_map == iSP);
    if (frameID == length(spmap))
        % We don't care about the last frame
        continue;
    end
    sub_seg = zeros(size(spmap{1}));
    sub_seg(spmap{frameID} == localSPID) = cluster_id;
    segments(:,:,frameID) = segments(:,:,frameID) + sub_seg;
end

result_path = fullfile(result_dir, ['seg_' video_name '_nonregression.mat']);
save(result_path, 'segments');
a = 3;

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

function graph = buildGraph(set_of_features, model, iFrame1, iFrame2, global_spid_map)

max_global_sp = max(global_spid_map(:));
graph = sparse(max_global_sp, max_global_sp);

topo = set_of_features{1};
idx = find(tril(topo ~= 0));
data = zeros(length(idx), length(set_of_features));
for i = 1:length(set_of_features)
    feature = set_of_features{i};
    data(:, i) = feature(idx);
end

%predicted_label = svmpredict(zeros(size(data, 1), 1), data, model, '-q');
predicted_label = sum(data, 2);

[id1, id2] = find(tril(topo ~= 0));

global_id1 = global_spid_map(iFrame1, id1);
global_id2 = global_spid_map(iFrame2, id2);
flat_global_id1 = sub2ind([max_global_sp, max_global_sp], global_id1, global_id2);
graph(flat_global_id1) = predicted_label;
flat_global_id2 = sub2ind([max_global_sp, max_global_sp], global_id2, global_id1);
graph(flat_global_id2) = predicted_label;

end






