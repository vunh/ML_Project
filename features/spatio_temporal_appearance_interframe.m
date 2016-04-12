function spatio_temporal_appearance_interframe...
    (spmap1, spmap2,...
    median_list1, median_list2, histogram_list1, histogram_list2,...
    optical_flow, global_spid_map, iFrame)

no_sp1 = size(median_list1, 1);
no_sp2 = size(median_list2, 1);

of_u_arr = optical_flow(:,:,1); of_u_arr = of_u_arr(:);
of_v_arr = optical_flow(:,:,2); of_v_arr = of_v_arr(:);

for i = 1:no_sp1
    % Compute median optical flow
    idx = find(spmap1(:) == i);
    [point_y, point_y] = find(spmap1(:) == i);
    u_list = of_u_arr(idx);
    v_list = of_v_arr(idx);
    flow = [median(u_list) median(v_list)];
    
    % Move the mask of the superpixel 1 to the next frame
    mask1 = (spmap1 == i);
    shifted_mask1 = shiftImg(mask1, flow);
    % Map the shifted mask to the next frame
    mapped = spmap2(shifted_mask1);
    [count_sp2,sp_id2]=hist(mapped,unique(mapped));
    
    weight = count_sp2 ./ sum(mask1(:));
    
    global_sp1 = global_spid_map(iFrame, sp1);
    global_sp_list2 = global_spid_map(iFrame + 1, sp_id2);
    
    lab_sim_graph(global_sp1, global_sp_list2) = exp(-lambda_sta * norm(median_list1(sp1, :) - median_list2(sp_id2, :)));
    lab_sim_graph(global_sp_list2, global_sp1) = lab_sim_graph(global_sp1, global_sp_list2);
    
    hist_sim_graph(global_sp1, global_sp2) = exp(-lambda_sta_2*computingChi2Dist(histogram_list(sp1, :), histogram_list(sp2, :)));
    hist_sim_graph(global_sp2, global_sp1) = hist_sim_graph(global_sp1, global_sp2);
end

end

