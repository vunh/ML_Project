function createTrainingData_FromVideo()

video_path = '';
anno_path = '';

pos_samples = [];
neg_samples = [];

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
for i = 1:length(intra_graph)
    
end

for i = 1:length(inter_graph)
end

end

function segment_id = getMostOverlapSegment(superpixel_mask, gt)

% Param
area_ratio_threshold = 0.6;

segment_id = 0;

overlap_gt = gt(logical(superpixel_mask));
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






