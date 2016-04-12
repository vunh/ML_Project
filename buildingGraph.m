function sim_graph = buildingGraph (frames, global_spid_map, supixel)

%% Params
weight_aba = 0.5;
weight_sta_median = 0.25;
weight_sta_hist = 0.25;

graph = zeros(size(global_spid_map,2), size(global_spid_map,2));
spatio_connect_graph = {}

%% Extract features
% Across Boundary Appearance
aba_graph = zeros(size(global_spid_map,2), size(global_spid_map,2));
for iFrame = 1:n_frames
    aff_aba = across_boundary_appearance(supixel(iFrame).spmap, supixel(iFrame).ucm);
    curr_no_sp = length(unique(supixel(1).spmap));
    for i = 1:curr_no_sp-1
        for j = i+1:curr_no_sp
            global_i = global_spid_map(iFrame, i);
            global_j = global_spid_map(iFrame, j);
            aba_graph(global_i, global_j) = aff_aba(i,j);
            aba_graph(global_j, global_i) = aba_graph(global_i, global_j);
        end
    end
    
    spatio_connect = zeros(size(aff_aba));
    spatio_connect(aff_aba ~= 0);
    spatio_connect_graph = [spatio_connect_graph {spatio_connect}];
end



% Spatio-temporal appearance
for iFrame = 1:nFrame
    % Compute Lab for this frame
    lab_img1 = rgb2lab(frames(iFrame));
    
    %% Intra-frame
    % Take the lower triangular matrix of the spatio connect graph
    tril_connect1 = tril(spatio_connect_graph{iFrame});
    [sp_list_a, sp_list_b] = find(tril_connect1 ~= 0);
    % Compute median and histogram of superpixels
    [median_list1, histogram_list1] = getLabInformation (supixel(iFrame).spmap, lab_img1);
    [lab_sim_graph, hist_sim_graph] = spatio_temporal_appearance_intraframe...
                ([sp_list_a, sp_list_b], median_list1, histogram_list1, global_spid_map, iFrame);
            
	%% Inter-frame
    if (iFrame < nFrame)
        lab_img2 = rgb2lab(frames(iFrame + 1));
        [median_list2, histogram_list2] = getLabInformation (supixel(iFrame + 1).spmap, lab_img2);
        spatio_temporal_appearance_interframe...
                    (supixel(iFrame).spmap, supixel(iFrame+1).spmap,...
                    median_list1, median_list2, histogram_list1, histogram_list2,...
                    optical_flow, global_spid_map, iFrame)
    end
end


% Combine component similarity graphs
sim_graph = weight_aba*aba_graph + ...
           weight_sta_median*lab_sim_graph + weight_sta_hist*hist_sim_graph;


end




