function [n_pos_intra, n_neg_intra, n_pos_inter, n_neg_inter] = countNumberSamples(train_dir)

files = dir(fullfile(train_dir, '*.mat'));
files = {files.name};
n_pos_intra = 0;
n_neg_intra = 0;
n_pos_inter = 0;
n_neg_inter = 0;
for iFile = 1:length(files)
    file_dir = fullfile(train_dir, files{iFile});
    sub_data = load(file_dir);
    
    n_pos_intra = n_pos_intra + size(sub_data.pos_samples_intra, 2);
    n_neg_intra = n_neg_intra + size(sub_data.neg_samples_intra, 2);
    n_pos_inter = n_pos_inter + size(sub_data.pos_samples_inter, 2);
    n_neg_inter = n_neg_inter + size(sub_data.neg_samples_inter, 2);
end

end