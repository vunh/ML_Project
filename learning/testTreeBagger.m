function testTreeBagger ()

% trainData = [ ...
%     [6,  300,  1];
%     [3,  300,  0];
%     [8,  300,  1];
%     [11, 2000, 0];
%     [3,  100,  0];
%     [6,  1000, 0];
%     ];
% 
% features = trainData(:,(1:2));
% classLabels = trainData(:,3);
% 
% nTrees = 20;
% 
% B = TreeBagger(nTrees,features,classLabels, 'Method', 'regression');
% 
% % Given a new individual WITH the features and WITHOUT the class label,
% % what should the class label be?
% newData = rand(10,2);
% 
% % Use the trained Decision Forest.
% 
% predChar1 = B.predict([6, 1000]);
% predChar2 = B.predict([6, 300]);
% 
% disp(predChar1);
% disp(predChar2);

addpath(genpath('/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/RandomTree/'));

trainData = [ ...
    [6,  300,  1];
    [3,  300,  0];
    [8,  300,  1];
    [11, 2000, 0];
    [3,  100,  0];
    [6,  1000, 0];
    ];

features = trainData(:,(1:2));
classLabels = trainData(:,3);

%acc = svmtrain(classLabels, features, sprintf('-s 4 -t 2 -c %f -g %f', 10, 0.5));
model = svmtrain(classLabels, features, sprintf('-s 4 -t 2 -c %f -g %f -q', 10, 0.5));
[predicted_label] = svmpredict(ones(1, 1), [5,300], model, '-q');
disp(predicted_label);

end