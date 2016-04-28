function graph = addFeature_SpatioTemporalAppearance ...
    (frames, spmap, global_spid_map, input_graph, intragraph, intergraph)

graph = sparase(size(input_graph));


for iSubGraph = 1:length(intragraph)
    tril_connect1 = tril(intragraph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect1 ~= 0);
    % Compute median and histogram of superpixels
    [median_list1, histogram_list1] = getLabInformation (spmap{iSubGraph}, frames{iSubGraph});
    [lab_sim_graph, hist_sim_graph] = spatio_temporal_appearance_intraframe...
                ([sp_list_a, sp_list_b], median_list1, median_list1, histogram_list1, histogram_list1,...
                iSubGraph, iSubGraph, global_spid_map);
	graph = graph + lab_sim_graph;
    graph = graph + hist_sim_graph;
    
end

for iSubGraph = 1:length(intergraph)
    tril_connect = tril(intergraph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect ~= 0);
    [median_list1, histogram_list1] = getLabInformation (spmap{iSubGraph}, frames{iSubGraph});
    [median_list2, histogram_list2] = getLabInformation (spmap{iSubGraph+1}, frames{iSubGraph+1});
    [lab_sim_graph, hist_sim_graph] = spatio_temporal_appearance_intraframe...
                ([sp_list_a, sp_list_b], median_list1, median_list2, histogram_list1, histogram_list2,...
                iSubGraph, (iSubGraph+1), global_spid_map);
            
            
	graph = graph + lab_sim_graph;
    graph = graph + hist_sim_graph;
end

end