function [graph, feature_aba] = addFeature_AccrossBoundaryAppearance (spmap, ucmmap, global_spid_map, input_graph, intragraph)

graph = sparse(size(input_graph, 1), size(input_graph, 1));
feature_aba = cell(length(intragraph), 1);

for iSubGraph = 1:length(intragraph)
    subspmap = spmap{iSubGraph};
    subucmmap = ucmmap{iSubGraph};
    aff_aba = across_boundary_appearance(uint16(subspmap), subucmmap);
    
    for i = 1:size(subspmap, 1)
        for j = 1:size(subspmap, 1)
            global_i = global_spid_map(iSubGraph, i);
            global_j = global_spid_map(iSubGraph, j);
            graph(global_i, global_j) = aff_aba(i,j);
            graph(global_j, global_i) = aff_aba(j,i);
        end
    end
    
    if (nargout > 1)
        feature_aba(iSubGraph) = {aff_aba};
    end
    
end

end