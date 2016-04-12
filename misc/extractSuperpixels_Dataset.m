function extractSuperpixels_Dataset()



dataset_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std';
intermediate_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_SegTrack_v2';
ext = '.png';
size = [];


% Get a list of all files and folders in this folder.
files = dir(dataset_dir);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
dir_list = files(dirFlags);
% Print folder names to command window.

poolobj = parpool('local',2);

parfor k = 1 : length(dir_list)
	dir_name = dir_list(k).name;
    dir_path = fullfile(dataset_dir, dir_name);
    
    if (strcmp(dir_name, '.') == 1 || strcmp(dir_name, '..') == 1)
        continue;
    end
    
    % Get the list of images with the correct order
    img_list = dir(fullfile(dir_path, ['*' ext]));
    img_list = {img_list.name};
    img_list_num = [];
    for iImg = 1:length(img_list)
        [~, img_name, ~] = fileparts(img_list{iImg});
        img_list_num = [img_list_num; str2num(img_name)];
    end
    [~, index] = sort(img_list_num);
    img_list = img_list(index);
    
    % Do superpixelization on the video
    superpixelVideo(dir_path, intermediate_dir, img_list, size);
end

delete(poolobj);

end