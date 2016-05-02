function [graph, feature_intra, feature_inter] = addFeature_SpatioTemporalMotion ...
    (spmap, global_spid_map, input_graph, intragraph, intergraph, op_flow, option)

graph = sparse(size(input_graph, 1), size(input_graph, 1));
feature_intra = cell(length(intragraph), 1);
feature_inter = cell(length(intergraph), 1);

for iSubGraph = 1:length(intragraph)
    subOpticalFlow = op_flow(iSubGraph);
    tril_connect1 = tril(intragraph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect1 ~= 0);
    % Compute median and histogram of superpixels
    [median_list1, histogram_list1] = getLabInformation (spmap{iSubGraph}, subOpticalFlow);
    [mo_sim_graph, mo_hist_sim_graph] = spatioTemporalMotion...
        ([sp_list_a, sp_list_b], median_list1, median_list1, histogram_list1, histogram_list1,...
                iSubGraph, iSubGraph, global_spid_map);
            
	graph = graph + option.mo_sim_weight * mo_sim_graph;
    graph = graph + option.mo_hist_weight * mo_hist_sim_graph;
    
    if (nargout > 1)
        feature_intra(iSubGraph, 1) = {option.mo_sim_weight * mo_sim_graph + option.mo_hist_weight * mo_hist_sim_graph};
    end
end

for iSubGraph = 1:length(intergraph)
    subOpticalFlow1 = op_flow(iSubGraph);
    subOpticalFlow2 = op_flow(iSubGraph + 1);
    tril_connect = tril(intergraph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect ~= 0);
    [median_list1, histogram_list1] = getMotionInformation (spmap{iSubGraph}, subOpticalFlow1);
    [median_list2, histogram_list2] = getMotionInformation (spmap{iSubGraph+1}, subOpticalFlow2);
    [mo_sim_graph, mo_hist_sim_graph] = spatioTemporalMotion...
        ([sp_list_a, sp_list_b], median_list1, median_list2, histogram_list1, histogram_list2,...
                iSubGraph, (iSubGraph+1), global_spid_map);
            
	graph = graph + option.mo_sim_weight * mo_sim_graph;
    graph = graph + option.mo_hist_weight * mo_hist_sim_graph;
    
    if (nargout > 1)
        feature_inter(iSubGraph, 1) = {option.mo_sim_weight * mo_sim_graph + option.mo_hist_weight * mo_hist_sim_graph};
    end
end

end

