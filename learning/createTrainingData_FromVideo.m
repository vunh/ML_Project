function createTrainingData_FromVideo()

video_path = '';
anno_path = '';
res_dir = '';


pos_samples_intra = [];
neg_samples_intra = [];
pos_samples_inter = [];
neg_samples_inter = [];

files = dir(video_path);
files = {files.name};

graphs = sparse();  % Put sth here
[intra_graph, inter_graph] = graph_topo (sp_map, global_spid_map, op_flow);

aff_aba = addFeature_AccrossBoundaryAppearance ({sp.spmap}, {sp.ucm}, global_spid_map, graph, intra_graph);
aff_sta = addFeature_SpatioTemporalAppearance ...
    (frames, {sp.spmap}, global_spid_map, graph, intra_graph, inter_graph);
aff_stm = addFeature_SpatioTemporalMotion ...
    ({sp.spmap}, global_spid_map, graph, intragraph, intergraph, op_flow);

% Compare with groundtruth
groundtruth = groundTruth{1,end}.Segmentation;
for iSubGraph = 1:length(intra_graph)
    subSPMap = spmap{iSubGraph};
    gt_frame = gtmap{iSubGraph};
    
    % Features on this frame
    sub_aba;
    sub_sta;
    sub_stm;
    
    
    % For each pair of superpixels
    tril_connect1 = tril(intra_graph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect1 ~= 0);
    for iPair = 1:size(sp_list_a, 1)
        id_seg_a = getMostOverlapSegment((subSPMap==sp_list_a(iPair)), gt_frame);
        id_seg_b = getMostOverlapSegment((subSPMap==sp_list_b(iPair)), gt_frame);
        added_sample = [sub_aba(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_sta(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_stm(sp_list_a(iPair), sp_list_b(iPair))];
        if (id_seg_a == id_seg_b)
            pos_samples_intra = [pos_samples_intra added_sample];
        else
            neg_samples_intra = [neg_samples_intra added_sample];
        end
    end
end

for i = 1:length(inter_graph)
    subSPMap1 = spmap{iSubGraph};
    subSPMap2 = spmap{iSubGraph+1};
    gt_frame1 = gtmap{iSubGraph};
    gt_frame2 = gtmap{iSubGraph+1};
    
    % Feature on this pair of frames
    sub_sta;
    sub_stm;
    
    
    tril_connect = tril(inter_graph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect ~= 0);
    for iPair = 1:size(sp_list_a, 1)
        id_seg_a = getMostOverlapSegment((subSPMap1==sp_list_a(iPair)), gt_frame1);
        id_seg_b = getMostOverlapSegment((subSPMap2==sp_list_b(iPair)), gt_frame2);
        added_sample = [sub_sta(sp_list_a(iPair), sp_list_b(iPair));...
                        sub_stm(sp_list_a(iPair), sp_list_b(iPair))];
        if (id_seg_a == id_seg_b)
            pos_samples_inter = [pos_samples_inter added_sample];
        else
            neg_samples_inter = [neg_samples_inter added_sample];
        end
    end
end


% Write to result file
if (video_path(end) == '/')
    video_path(end) = [];
end
[~,video_name,~] =fileparts(video_path);
save(fullfile(res_dir, [video_name '.mat']),...
    'pos_samples_intra', 'neg_samples_intra', 'pos_samples_inter', 'neg_samples_inter');

end

function segment_id = getMostOverlapSegment(superpixel_mask, gt_frame)

% Param
area_ratio_threshold = 0.7;

segment_id = 0;

overlap_gt = gt_frame(logical(superpixel_mask));
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

end






