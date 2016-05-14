function [mo_sim_graph, mo_hist_sim_graph] = spatioTemporalMotion...
    (sp_pairs, median_list1, median_list2, histogram_list1, histogram_list2, sim_matrix_size, option)


% This function borrows spatio_temporal_appearance_intraframe function
% because they are technically the same

[mo_sim_graph, mo_hist_sim_graph] = spatio_temporal_appearance_intraframe...
    (sp_pairs, median_list1, median_list2, histogram_list1, histogram_list2, sim_matrix_size, option);


end