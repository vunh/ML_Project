function extractOpticalFlowv_Dataset()

addpath(genpath('/home/vhnguyen/code/ml_proj/code/flow_code_v2'));

dataset_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/vsb100/General_traindense_halfres/Images';
output_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/opticalflow_vsb100_traindensehalf';
ext = '.jpg';

poolobj = parpool('local',2);

% Get a list of all files and folders in this folder.
files = dir(dataset_dir)
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir]
% Extract only those that are directories.
subFolders = files(dirFlags)
% Print folder names to command window.
parfor k = 1 : length(subFolders)
    video_name = subFolders(k).name;
    if (strcmp(video_name, '.') == 1 || strcmp(video_name, '..') == 1)
	continue;
    end
    extractOpticalFlow_Video(dataset_dir, video_name, output_dir, ext);
end

delete(poolobj);

end

function extractOpticalFlow_Video(dataset_dir, video_name, output_dir, ext)

video_dir = fullfile(dataset_dir, video_name);

files = dir(fullfile(video_dir, ['*' ext]));
files = {files.name};
im1 = imread(fullfile(video_dir, files{1}));
im2 = [];
o_flow = [];
for i = 2:length(files)
    frame_path = fullfile(video_dir, files{i});
    im2 = imread(frame_path);
    
    % Process
    of = estimate_flow_interface(im1,im2);
    o_flow(i - 1).u = of(:,:,1);
    o_flow(i - 1).v = of(:,:,2);
    
    % Update
    im1 = im2;
end

save(fullfile(output_dir, [video_name, '.mat']), 'o_flow');

end
