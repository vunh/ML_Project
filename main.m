function main()

% Config
nbCluster = 200;

addpath(genpath(pwd));
addpath(genpath('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/Ncut_9'));

% Params
video_name = 'frog';

% Auxiliary params
ext = '.png';
dataset_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std';
superpixel_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_SegTrack_v2';
opticalflow_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/opticalflow_SegTrack_v2';
working_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/working_dir';

%% Load information
% Load frames
frames = load_frames(fullfile(dataset_dir, video_name), ext);
% Load superpixels
load(fullfile(superpixel_dir, ['spinfo_' video_name]));
% Load optical flow
load(fullfile(opticalflow_dir, video_name));


%% Build the affinity graph/map
% Find maximum number of superpixels in a frame
max_no_superpixel = 0;
for i = 1:length(sp)
    curr_no_sp = length(unique(sp(i).spmap));
    if (max_no_superpixel < curr_no_sp)
        max_no_superpixel = curr_no_sp;
    end
end

% Total number of superpixels in this video, create global mapping from 
n_frame = length(sp);
n_sp = 0;
global_spid_map = zeros(n_frame, max_no_superpixel);   % Global superpixel index mapping
for i = 1:length(sp)
    curr_no_sp = length(unique(sp(i).spmap));
    
    global_spid_map(i,1:curr_no_sp) = (n_sp+1):(n_sp+curr_no_sp);
    
    n_sp = n_sp + curr_no_sp;
end


% Build graph topology
graph_topo_file = fullfile(working_dir, ['graph_topo_' video_name '.mat']);
if (exist(graph_topo_file, 'file') == 2)
    load (graph_topo_file);
else
    [intra_graph, inter_graph] = graph_topo({sp.spmap}, global_spid_map, o_flow);
    save(graph_topo_file, 'intra_graph', 'inter_graph');
end

graph = sparse(n_sp, n_sp);
% Feed features to the graph
feature_file = fullfile(working_dir, ['features_' video_name '.mat']);
if (exist(feature_file, 'file') == 2)
    load (feature_file);
end


% For each type of feature, check whether it is computed
%% Compute features
if (exist('aff_aba') ~= 1)
    aff_aba = addFeature_AccrossBoundaryAppearance ({sp.spmap}, {sp.ucm}, global_spid_map, graph, intra_graph);
end

if (exist('aff_sta') ~= 1)
    aff_sta = addFeature_SpatioTemporalAppearance ...
        (frames, {sp.spmap}, global_spid_map, graph, intra_graph, inter_graph);
end

save (feature_file, 'aff_aba', 'aff_sta');
fprintf('\nFinish computing features');

graph = graph + aff_aba + aff_sta;

% Using NCut to partition the graph
[NcutDiscrete,NcutEigenvectors,NcutEigenvalues] = ncutW(graph,nbCluster);

end

function frames = load_frames(video_dir, ext)

frames = [];

files = dir(fullfile(video_dir, ['*' ext]));
files = {files.name};
for i = 1:length(files)
    frame_path = fullfile(video_dir, files{i});
    frames(:,:,:,i) = rgb2lab(imread(frame_path));
end



end
