function extractSuperpixels_Dataset()



dataset_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/vsb100/General_traindense_halfres/Images';
intermediate_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_vsb100_traindensehalf';
ext = '.jpg';
size = [];


% Get a list of all files and folders in this folder.
files = dir(dataset_dir);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
dir_list = files(dirFlags);
% Print folder names to command window.

%poolobj = parpool('local',2);

for k = 1 : length(dir_list)
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
        full_img_name = img_list{iImg};
        full_img_name = full_img_name(1, findFirstNumberId(full_img_name):end);
        [~, img_name, ~] = fileparts(full_img_name);
        img_list_num = [img_list_num; str2num(img_name)];
    end
    [~, index] = sort(img_list_num);
    img_list = img_list(index);
    
    % Do superpixelization on the video
    superpixelVideo(dir_path, intermediate_dir, img_list, size);
end

%delete(poolobj);

end

function id = findFirstNumberId(str)
id = 0;
for i = 1:length(str)
    if (str(i) >= '0' && str(i) <= '9')
        id = i;
        break;
    end
end

end