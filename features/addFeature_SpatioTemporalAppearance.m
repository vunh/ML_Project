function [graph, feature_intra_sim, feature_intra_hist, feature_inter_sim, feature_inter_hist]...
    = addFeature_SpatioTemporalAppearance ...
    (frames, spmap, global_spid_map, input_graph, intragraph, intergraph, option)

graph = sparse(size(input_graph, 1), size(input_graph, 1));
feature_intra_sim = cell(length(intragraph), 1);
feature_inter_sim = cell(length(intergraph), 1);
feature_intra_hist = cell(length(intragraph), 1);
feature_inter_hist = cell(length(intergraph), 1);

for iSubGraph = 1:1         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for iSubGraph = 1:length(intragraph)
    tril_connect1 = tril(intragraph{iSubGraph});
    [sp_list_a, sp_list_b] = find(tril_connect1 ~= 0);
    % Compute median and histogram of superpixels
    [median_list1, histogram_list1] = getLabInformation (spmap{iSubGraph}, frames(:,:,:,iSubGraph),option);
    [lab_sim_graph, hist_sim_graph] = spatio_temporal_appearance_intraframe...
                ([sp_list_a, sp_list_b], median_list1, median_list1, histogram_list1, histogram_list1,...
                size(tril_connect1), option);
	%graph = graph + lab_sim_graph;
    %graph = graph + hist_sim_graph;
    
    if (nargout > 1)
        feature_intra_sim(iSubGraph, 1) = {lab_sim_graph};
        feature_intra_hist(iSubGraph, 1) = {hist_sim_graph};
    end
    
end

for iSubGraph = 1:1         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for iSubGraph = 1:length(intergraph)
    %tril_connect = tril(intergraph{iSubGraph});
    tril_connect = intergraph{iSubGraph};
    [sp_list_a, sp_list_b] = find(tril_connect ~= 0);
    [median_list1, histogram_list1] = getLabInformation (spmap{iSubGraph}, frames(:,:,:,iSubGraph),option);
    [median_list2, histogram_list2] = getLabInformation (spmap{iSubGraph+1}, frames(:,:,:,iSubGraph+1),option);
    [lab_sim_graph, hist_sim_graph] = spatio_temporal_appearance_intraframe...
                ([sp_list_a, sp_list_b], median_list1, median_list2, histogram_list1, histogram_list2,...
                size(tril_connect),option);
            
            
	%graph = graph + lab_sim_graph;
    %graph = graph + hist_sim_graph;
    
    if (nargout > 1)
        feature_inter_sim(iSubGraph, 1) = {lab_sim_graph};
        feature_inter_hist(iSubGraph, 1) = {hist_sim_graph};
    end
end

end