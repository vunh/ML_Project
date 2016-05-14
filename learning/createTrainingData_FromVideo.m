function createTrainingData_FromVideo(video_name)

% Param
groundTruth_level = 4;

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
option_sta.lambda_inter_sta = 40;
option_sta.lambda_inter_sta_2 = 70;

option_stm.nbins = 20;
option_stm.motion_range = [-10, 10];
%option_stm.lambda_sta = 20;
option_stm.lambda_sta = 10;
option_stm.lambda_sta_2 = 50;
%option_stm.g1 = 1;
%option_stm.g1 = 4;
%option_stm.g2 = 0.5;
option_stm.lambda_inter_sta = 40;
option_stm.lambda_inter_sta_2 = 70;



addpath(genpath('../'));

% Directories
video_path =        ['/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/vsb100/General_traindense_halfres/Images/' video_name];
superpixel_path=    ['/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_vsb100_traindensehalf/spinfo_' video_name '.mat'];
opticalflow_path =  ['/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/opticalflow_vsb100_traindensehalf/' video_name '.mat'];
anno_path =         ['/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/vsb100/General_traindense_halfres/Groundtruth/' video_name];
working_dir =       ['/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/generated_trainingset_vsb100/working_dir'];

res_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/generated_trainingset_vsb100';

% if (video_path(end) == '/')
%     video_path(end) = [];
% end
% [~,video_name,~] =fileparts(video_path);


pos_samples_intra = full([]);
neg_samples_intra = full([]);
pos_samples_inter = full([]);
neg_samples_inter = full([]);

segment_gt = loadGroundTruth (anno_path, groundTruth_level);
frames = loadLabFrame (video_path, '.jpg');
sp = load(superpixel_path);  sp = sp.sp;
spmap = {sp.spmap};
ucm = {sp.ucm};
op_flow = load(opticalflow_path); op_flow = op_flow.o_flow;







% =========================================================================
% Build the affinity graph/map
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

graph_topo_file = fullfile(working_dir, sprintf('graph_topo_%s.mat', video_name));
if (exist(graph_topo_file, 'file') == 2)
load(graph_topo_file);
else
[intra_graph, inter_graph] = graph_topo (spmap, global_spid_map, op_flow);
save(graph_topo_file, 'intra_graph', 'inter_graph');
end
graph = sparse(n_sp, n_sp);







% =========================================================================
feature_file = fullfile(working_dir, sprintf('feature_%s.mat', video_name));
if (exist(feature_file, 'file') == 2)
    load(feature_file);
else
[gr_aba, aff_aba] = addFeature_AccrossBoundaryAppearance (spmap, ucm, global_spid_map, graph, intra_graph, option_aba);
[sta_graph, sta_feature_intra_sim, sta_feature_intra_hist, sta_feature_inter_sim, sta_feature_inter_hist] = addFeature_SpatioTemporalAppearance ...
    (frames, spmap, global_spid_map, graph, intra_graph, inter_graph, option_sta);
[stm_graph, stm_feature_intra_sim, stm_feature_intra_hist, stm_feature_inter_sim, stm_feature_inter_hist] = addFeature_SpatioTemporalMotion ...
    (spmap, global_spid_map, graph, intra_graph, inter_graph, op_flow, option_stm);
save(feature_file, 'aff_aba', 'sta_feature_intra_sim', 'sta_feature_intra_hist', 'sta_feature_inter_sim', 'sta_feature_inter_hist',...
    'stm_feature_intra_sim', 'stm_feature_intra_hist', 'stm_feature_inter_sim', 'stm_feature_inter_hist');
end


% Compare with groundtruth
% We only consider n-1 frames because the last frame does not have motion
% information

for iSubGraph = 1:(length(intra_graph)-1)
    subSPMap = spmap{iSubGraph};
    gt_frame = segment_gt(:,:,iSubGraph);
    
    % Features on this frame
    sub_aba = aff_aba{iSubGraph};
    sub_sta_sim = sta_feature_intra_sim{iSubGraph};
    sub_sta_hist = sta_feature_intra_hist{iSubGraph};
    sub_stm_sim = stm_feature_intra_sim{iSubGraph};
    sub_stm_hist = stm_feature_intra_hist{iSubGraph};
    
    
    % For each pair of superpixels
    tril_connect1 = tril(intra_graph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect1 ~= 0);
    for iPair = 1:size(sp_list_a, 1)
        [id_seg_a, id_hostseg_a] = getMostOverlapSegment((subSPMap==sp_list_a(iPair)), gt_frame);
        [id_seg_b, id_hostseg_b] = getMostOverlapSegment((subSPMap==sp_list_b(iPair)), gt_frame);
        added_sample = [sub_aba(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_sta_sim(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_sta_hist(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_stm_sim(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_stm_hist(sp_list_a(iPair), sp_list_b(iPair))];
        if (id_seg_a == id_seg_b)
            pos_samples_intra = [pos_samples_intra full(added_sample)];
        elseif (id_hostseg_a ~= id_hostseg_b)
            neg_samples_intra = [neg_samples_intra full(added_sample)];
        end
    end
end

for iSubGraph = 1:(length(inter_graph)-1)
    subSPMap1 = spmap{iSubGraph};
    subSPMap2 = spmap{iSubGraph+1};
    gt_frame1 = segment_gt(:,:,iSubGraph);
    gt_frame2 = segment_gt(:,:,iSubGraph+1);
    
    % Feature on this pair of frames
    sub_sta_sim = sta_feature_inter_sim{iSubGraph};
    sub_sta_hist = sta_feature_inter_hist{iSubGraph};
    sub_stm_sim = stm_feature_inter_sim{iSubGraph};
    sub_stm_hist = stm_feature_inter_hist{iSubGraph};
    
    
    %tril_connect = tril(inter_graph{iSubGraph});
    tril_connect = inter_graph{iSubGraph};
    [sp_list_a, sp_list_b] = find(tril_connect ~= 0);
    for iPair = 1:size(sp_list_a, 1)
        [id_seg_a, id_hostseg_a] = getMostOverlapSegment((subSPMap1==sp_list_a(iPair)), gt_frame1);
        [id_seg_b, id_hostseg_b] = getMostOverlapSegment((subSPMap2==sp_list_b(iPair)), gt_frame2);
        
        added_sample = [sub_sta_sim(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_sta_hist(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_stm_sim(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_stm_hist(sp_list_a(iPair), sp_list_b(iPair))];
        if (id_seg_a == id_seg_b)
            pos_samples_inter = [pos_samples_inter full(added_sample)];
        elseif (id_hostseg_a ~= id_hostseg_b)
            neg_samples_inter = [neg_samples_inter full(added_sample)];
        end
    end
end


% Write to result file
%pos_samples_intra = full(pos_samples_intra);

save(fullfile(res_dir, [video_name '.mat']),...
    'pos_samples_intra', 'neg_samples_intra', 'pos_samples_inter', 'neg_samples_inter');

end

function [segment_id, host_segment_id] = getMostOverlapSegment(superpixel_mask, gt_frame)

% Param
area_ratio_threshold = 0.6;

segment_id = 0;

%overlap_gt = gt_frame .* superpixel_mask;

overlap_gt = gt_frame(superpixel_mask);

seg_list = unique(overlap_gt);
max_seg_id = 0;
max_seg_area = 0;
for i = 1:length(seg_list)
    mask = (overlap_gt == seg_list(i));
    area = sum(mask(:));
    if (area > max_seg_area)
        max_seg_id = seg_list(i);
        max_seg_area = area;
    end
end

sp_area = sum(superpixel_mask(:));
if (max_seg_area/sp_area > area_ratio_threshold)
    segment_id = max_seg_id;
end
host_segment_id = max_seg_id;

end


function segment_gt = loadGroundTruth (gt_path, level)

files = dir(fullfile(gt_path, '*.mat'));
files = {files.name};
for i = 1:length(files)
    temp = load(fullfile(gt_path,files{i}));
    temp = temp.groundTruth;
    segment_gt(:,:,i) = temp{1,level}.Segmentation;
end

end

function frames = loadLabFrame (video_path, ext)

files = dir(fullfile(video_path, ['*' ext]));
files = {files.name};
for i = 1:length(files)
    frames(:,:,:,i) = rgb2lab(imread(fullfile(video_path,files{i})));
end

end





