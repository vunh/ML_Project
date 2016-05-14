% This function is used for calculating the adjacent graph
% edge connecting adjacent nodes would be 1
% otherwise would be 0
% The indices here are local

function [intra_graph, inter_graph] = graph_topo (sp_map, global_spid_map, op_flow)



n_global_sp = max(global_spid_map(:));
n_frame = length(sp_map);

intra_graph = cell(n_frame, 1);
inter_graph = cell(n_frame-1, 1);

%% Intra graph
for iFrame = 1:n_frame
    spmap = sp_map{iFrame};
    no_sp = length(unique(spmap));
    
    aff_aba = across_boundary_appearance(uint16(spmap), ones(size(spmap)));
    sub_intra_graph = zeros(no_sp, no_sp);
%     for i = 1:no_sp
%         sub_intra_graph(i, i) = 1;
%         for j = i+1:no_sp
%             sub_intra_graph(i, j) = aff_aba(i,j);
%             sub_intra_graph(j, i) = sub_intra_graph(i, j);
%         end
%     end
    
    for i = 1:no_sp
        for j = 1:no_sp
            sub_intra_graph(i,j) = aff_aba(i,j);
            sub_intra_graph(j,i) = aff_aba(j,i);
        end
    end
    
    
    sub_intra_graph(sub_intra_graph ~= 0) = 1;
    intra_graph{iFrame} = sub_intra_graph;
end

%% Inter-graph
%for iFrame = 1:1
for iFrame = 1:(length(sp_map)-1)
    
    
    disp(iFrame);
    spmap1 = sp_map{iFrame};
    spmap2 = sp_map{iFrame + 1};
    no_sp1 = length(unique(spmap1));
    no_sp2 = length(unique(spmap2));
    
    sub_inter_graph = zeros(no_sp1, no_sp2);
    
    u_of = op_flow(iFrame).u; u_of = u_of(:);
    v_of = op_flow(iFrame).v; v_of = v_of(:);
    
    no_sp1 = length(unique(spmap1));
    
    for iSp = 1:no_sp1
        % Compute median optical flow
        idx = find(spmap1(:) == iSp);
        u_list = u_of(idx);
        v_list = v_of(idx);
        flow = [median(v_list) median(u_list)];
        
        % Move the mask of the superpixel 1 to the next frame
        mask1 = (spmap1 == iSp);
        shifted_mask1 = shiftImg(mask1, flow);
        
        % Put the shifted mask to the next frame
        intersect = spmap2(logical(shifted_mask1));
        %intersect = spmap2 .* uint32(shifted_mask1);
        npx_intersect = length(intersect(:));
        sp_list = unique(intersect);
        for i = 1:length(sp_list)
            weight = length(find (intersect == sp_list(i)));
            weight = weight / npx_intersect;
            
            sub_inter_graph(iSp, sp_list(i)) = weight;
        end
    end
    
    inter_graph{iFrame} = sub_inter_graph;
end

end