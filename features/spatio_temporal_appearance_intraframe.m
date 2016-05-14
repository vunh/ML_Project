% This function is for computing "Spatio-temporal appearance" similarities
% between superpixels with an image

function [lab_sim_graph, hist_sim_graph] = spatio_temporal_appearance_intraframe...
                (sp_pairs, median_list1, median_list2, histogram_list1, histogram_list2, sim_matrix_size)

% Params
lambda_sta = 20;
lambda_sta_2 = 10;
g1 = 1;
g2 = 0.5;

lab_sim_graph = sparse(sim_matrix_size(1,1), sim_matrix_size(1,2));
hist_sim_graph = sparse(sim_matrix_size(1,1), sim_matrix_size(1,2));

% Computing similarities for pairs
for iPair = 1:length(sp_pairs)
    sp1 = sp_pairs(iPair, 1);
    sp2 = sp_pairs(iPair, 2);
    %sp1 = global_spid_map(frameID1, sp1);
    %sp2 = global_spid_map(frameID2, sp2);
    % Median
    dist_lab = exp(-lambda_sta * norm(median_list1(sp1, :) - median_list2(sp2, :)));
    lab_sim_graph(sp1, sp2) = exp(-dist_lab/g1);
    lab_sim_graph(sp2, sp1) = lab_sim_graph(sp1, sp2);
    
    % Histogram
    dist_hist = exp(-lambda_sta_2*computingChi2Dist(histogram_list1(sp1, :), histogram_list2(sp2, :))/g2);
    hist_sim_graph(sp1, sp2) = dist_hist;
    hist_sim_graph(sp2, sp1) = hist_sim_graph(sp1, sp2);
end

% lab_sim_graph(lab_sim_graph == 0) = Inf;
% hist_sim_graph(hist_sim_graph == 0) = Inf;
% lab_sim_graph = exp(-lab_sim_graph);
% hist_sim_graph = exp(-hist_sim_graph);



end

function dist = computingChi2Dist(hist1, hist2)

numer = (hist1 - hist2) .^ 2;
denom = (hist1 + hist2);

dist = sum(numer / denom) /2;

end