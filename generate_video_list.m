function generate_video_list()

dataset_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/dataset/SegTrackv2/PNG_Std';
files = dir(dataset_dir);
dirFlags = [files.isdir]
files = files(dirFlags);
files = {files.name};


index = 1;
for i = 1:length(files)
    filename = files{i};
    if ((strcmp(filename, '.') == 1) || (strcmp(filename, '..') == 1))
        continue;
    end
    
    video_list(index).video_name = filename;
    video_list(index).ext = '.png';
    video_list(index).dataset_dir = dataset_dir;
    video_list(index).superpixel_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/superpixel_SegTrack_v2';
    video_list(index).opticalflow_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/opticalflow_SegTrack_v2';
    video_list(index).working_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/working_dir';
    video_list(index).svr_model_path = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/svr_model_vsb100/SVR_C10.000_G0.500.mat';
    video_list(index).result_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/method_results';
    index = index + 1;
end

save('video_list.mat', 'video_list');

end