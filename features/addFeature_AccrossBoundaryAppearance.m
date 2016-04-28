function graph = addFeature_AccrossBoundaryAppearance (spmap, ucmmap, global_spid_map, input_graph, intragraph)

graph = sparse(size(input_graph));

for iSubGraph = 1:length(intragraph)
    subspmap = spmap{iSubGraph};
    subucmmap = ucmmap{iSubGraph};
    aff_aba = across_boundary_appearance(subspmap, subucmmap);
    
    for i = 1:size(subspmap, 1)
        for j = 1:size(subspmap, 1)
            global_i = global_spid_map(iSubGraph, i);
            global_j = global_spid_map(iSubGraph, j);
            graph(global_i, global_j) = aff_aba(i,j);
            graph(global_j, global_i) = aff_aba(j,i);
        end
    end
end

end