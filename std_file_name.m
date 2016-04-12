function std_file_name (src_dir, des_dir, src_ext, des_ext)

if (exist(des_dir) ~= 7)
    mkdir(des_dir);
end

% Get a list of all files and folders in this folder.
files = dir(src_dir);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
file_list = files;
% Print folder names to command window.
iImg = 1;
for k = 1 : length(file_list)
	file_name = file_list(k).name;
    file_path = fullfile(src_dir, file_name);
    des_path = fullfile(des_dir, file_name);
    
    if (strcmp(file_name, '.') == 1 || strcmp(file_name, '..') == 1)
        continue;
    end
    
    % Check if the file is a folder --> recursive go deeper
    if (isdir(file_path))
        std_file_name(file_path, des_path, src_ext, des_ext);
        continue;
    end
    
    % Check file with appropriate ext
    [parent, f_name, f_ext] = fileparts(file_name);
    if (ismember(f_ext, src_ext) == 1)
        im = imread(file_path);
        new_des_path = fullfile(des_dir, sprintf('%.5d%s', iImg, des_ext));
        imwrite(im, new_des_path);
        iImg = iImg + 1;
        continue;
    end
    
    
end