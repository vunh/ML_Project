function [graph, feature_intra_sim, feature_intra_hist, feature_inter_sim, feature_inter_hist]...
    = addFeature_SpatioTemporalMotion ...
    (spmap, global_spid_map, input_graph, intragraph, intergraph, op_flow, option)

graph = sparse(size(input_graph, 1), size(input_graph, 1));
feature_intra_sim = cell(length(intragraph), 1);
feature_inter_sim = cell(length(intergraph), 1);
feature_intra_hist = cell(length(intragraph), 1);
feature_inter_hist = cell(length(intergraph), 1);

for iSubGraph = 1:1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for iSubGraph = 1:(length(intragraph) - 1)
    subOpticalFlow = op_flow(iSubGraph);
    tril_connect1 = tril(intragraph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect1 ~= 0);
    % Compute median and histogram of superpixels
    [median_list1, histogram_list1] = getMotionInformation (spmap{iSubGraph}, subOpticalFlow,option);
    [mo_sim_graph, mo_hist_sim_graph] = spatioTemporalMotion...
        ([sp_list_a, sp_list_b], median_list1, median_list1, histogram_list1, histogram_list1,...
                size(tril_connect1),option);
            
	%graph = graph + mo_sim_graph;
    %graph = graph + mo_hist_sim_graph;
    
    if (nargout > 1)
        feature_intra_sim(iSubGraph, 1) = {mo_sim_graph};
        feature_intra_hist(iSubGraph, 1) = {mo_hist_sim_graph};
    end
end

for iSubGraph = 1:1  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for iSubGraph = 1:(length(intergraph) - 1)
    subOpticalFlow1 = op_flow(iSubGraph);
    subOpticalFlow2 = op_flow(iSubGraph + 1);
    %tril_connect = tril(intergraph{iSubGraph});
    tril_connect = intergraph{iSubGraph};
    [sp_list_a, sp_list_b] = find(tril_connect ~= 0);
    [median_list1, histogram_list1] = getMotionInformation (spmap{iSubGraph}, subOpticalFlow1,option);
    [median_list2, histogram_list2] = getMotionInformation (spmap{iSubGraph+1}, subOpticalFlow2,option);
    [mo_sim_graph, mo_hist_sim_graph] = spatioTemporalMotion...
        ([sp_list_a, sp_list_b], median_list1, median_list2, histogram_list1, histogram_list2,...
                size(tril_connect),option);
            
	%graph = graph + mo_sim_graph;
    %graph = graph + mo_hist_sim_graph;
    
    if (nargout > 1)
        feature_inter_sim(iSubGraph, 1) = {mo_sim_graph};
        feature_inter_hist(iSubGraph, 1) = {mo_hist_sim_graph};
    end
end

end

