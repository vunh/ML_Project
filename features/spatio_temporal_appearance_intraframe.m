% This function is for computing "Spatio-temporal appearance" similarities
% between superpixels with an image

function [lab_sim_graph, hist_sim_graph] = spatio_temporal_appearance_intraframe...
                (sp_pairs, median_list, histogram_list, global_spid_map, iFrame)

% Params
lambda_sta = 0.5;
lambda_sta_2 = 0.5;

lab_sim_graph = zeros(size(global_spid_map,2));
hist_sim_graph = zeros(size(global_spid_map,2));

% Computing similarities for pairs
for iPair = 1:length(sp_pairs)
    sp1 = sp_pairs(iPair, 1);
    sp2 = sp_pairs(iPair, 2);
    global_sp1 = global_spid_map(iFrame, sp1);
    global_sp2 = global_spid_map(iFrame, sp2);
    % Median
    lab_sim_graph(global_sp1, global_sp2) = exp(-lambda_sta * norm(median_list(sp1, :) - median_list(sp2, :)));
    lab_sim_graph(global_sp2, global_sp1) = lab_sim_graph(global_sp1, global_sp2);
    
    % Histogram
    hist_sim_graph(global_sp1, global_sp2) = exp(-lambda_sta_2*computingChi2Dist(histogram_list(sp1, :), histogram_list(sp2, :)));
    hist_sim_graph(global_sp2, global_sp1) = hist_sim_graph(global_sp1, global_sp2);
end



end

function dist = computingChi2Dist(hist1, hist2)

numer = (hist1 - hist2) .^ 2;
denom = (hist1 + hist2);

dist = sum(numer / denom) /2;

end