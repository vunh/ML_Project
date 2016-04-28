function main()

addpath(genpath(pwd));

% Params
video_name = 'girl';

% Auxiliary params
ext = '.png';
video_dir = 'girl';
superpixel_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_SegTrack_v2';
opticalflow_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/opticalflow_SegTrack_v2';

%% Load information
% Load frames
frames = load_frames(video_dir, ext)
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
[intra_graph, inter_graph] = graph_topo({sp.spmap}, global_spid_map, o_flow);

graph = sparse(n_sp, n_sp);
% Feed features to the graph
graph = graph + addFeature_AccrossBoundaryAppearance ({sp.spmap}, {sp.ucm}, global_spid_map, graph, intra_graph);

% Using NCut to partition the graph
a = 3;

end

function frames = load_frames(video_dir, ext)

frames = [];

files = dir(fullfile(video_dir, ['*' ext]));
files = {files.name};
for i = 1:length(files)
    frame_path = fullfile(video_dir, files{i});
    frames(:,:,i) = imread(frame_path);
end

end
