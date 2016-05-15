

predicted_label = svmpredict(zeros(size(data_intra, 1), 1), sub_data, SVR_intra, '-q');
predicted_label = round(predicted_label);
acc=length(find(predicted_label == label_intra))/size(label_intra,1);
disp(acc);

% predicted_label = svmpredict(zeros(size(data_inter, 1), 1), data_inter, SVR_inter, '-q');
% predicted_label = round(predicted_label);
% acc=length(find(predicted_label == label_inter))/size(label_inter,1);
% disp(acc);