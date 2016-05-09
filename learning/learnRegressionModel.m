function learnRegressionModel ()

trainingData_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/generated_trainingset_vsb100';
res_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/output/svr_model_vsb100';

% Params
nTrees = 20;
limit_pos_intra = 400;
limit_neg_intra = 500;
limit_pos_inter = 400;
limit_neg_inter = 500;
[org_pos_intra, org_neg_intra, org_pos_inter, org_neg_inter] = countNumberSamples(trainingData_dir);
ratio_pos_intra = limit_pos_intra/org_pos_intra;
ratio_neg_intra = limit_neg_intra/org_neg_intra;
ratio_pos_inter = limit_pos_inter/org_pos_inter;
ratio_neg_inter = limit_neg_inter/org_neg_inter;

files = dir(fullfile(trainingData_dir, '*.mat'));
files = {files.name};

data_intra = [];
data_inter = [];
label_intra = [];
label_inter = [];

for iFile = 1:length(files)
    file_dir = fullfile(trainingData_dir, files{iFile});
    sub_data = load(file_dir);
    
    n_pos_intra = round(size(sub_data.pos_samples_intra, 2) * ratio_pos_intra);
    n_neg_intra = round(size(sub_data.neg_samples_intra, 2) * ratio_neg_intra);
    n_pos_inter = round(size(sub_data.pos_samples_inter, 2) * ratio_pos_inter);
    n_neg_inter = round(size(sub_data.neg_samples_inter, 2) * ratio_neg_inter);
    
    sub_pos_intra = datasample(sub_data.pos_samples_intra', n_pos_intra, 1, 'Replace', false);
    sub_neg_intra = datasample(sub_data.neg_samples_intra', n_neg_intra, 1, 'Replace', false);
    sub_pos_inter = datasample(sub_data.pos_samples_inter', n_pos_inter, 1, 'Replace', false);
    sub_neg_inter = datasample(sub_data.neg_samples_inter', n_neg_inter, 1, 'Replace', false);
    
    data_intra = [data_intra; sub_pos_intra; sub_neg_intra];
    label_intra = [label_intra; ones(n_pos_intra, 1); zeros(n_neg_intra, 1)];
    data_inter = [data_inter; sub_pos_inter; sub_neg_inter];
    label_inter = [label_inter; ones(n_pos_inter, 1); zeros(n_neg_inter, 1)];
    
end

C_param = 10;
G_param = 0.5;
disp('Begin training intra');
%RF_intra = TreeBagger(nTrees,data_intra,label_intra, 'Method', 'regression');
SVR_intra = svmtrain(label_intra, data_intra, sprintf('-s 4 -t 2 -c %f -g %f -q', C_param, G_param));
disp('Begin training inter');
%RF_inter = TreeBagger(nTrees,data_inter,label_inter, 'Method', 'regression');
SVR_inter = svmtrain(label_inter, data_inter, sprintf('-s 4 -t 2 -c %f -g %f -q', C_param, G_param));

res_file_name = sprintf('SVR_C%.3f_G%.3f.mat', C_param, G_param);
save(fullfile(res_dir, res_file_name), 'SVR_intra', 'SVR_inter');

end

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