function superpixelVideo(video_dir, intermediate_dir, file_name_list, imsize)

working_dir = '/Users/vunh/Documents/SBU/CourseWork/CSE512 - Machine Learning/Project/code/edges-master';
addpath(working_dir);
%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model=load(fullfile(working_dir, 'models/forest/modelBsds')); model=model.model;
model.opts.nms=-1; model.opts.nThreads=4;
model.opts.multiscale=0; model.opts.sharpen=2;

%% set up opts for spDetect (see spDetect.m)
opts = spDetect;
opts.nThreads = 4;  % number of computation threads
opts.k = 512;       % controls scale of superpixels (big k -> big sp)
opts.alpha = .5;    % relative importance of regularity versus data terms
opts.beta = .9;     % relative importance of edge versus color terms
opts.merge = 0;     % set to small value to merge nearby superpixels at end
opts.bounds = 0;    % There will be no boundaries between superpixels


sp = [];
for iImg = 1:length(file_name_list)
    im = imread(fullfile(video_dir, file_name_list{iImg}));
    if (~isempty(imsize))
        im = imresize(im, imsize);
    end
    [E,~,~,segs]=edgesDetect(im,model);
    [S,V] = spDetect(im,E,opts);
    [~,~,U]=spAffinities(S,E,segs,opts.nThreads);
    S = S + 1;  % SP'smallest index should be 1 instead of 0
    
    sp(iImg).edge = E;
    sp(iImg).spmap = S;
    sp(iImg).ucm = U;
end

if (video_dir(end) == '/')
    video_dir(end) = [];
end
[~, video_name, ~] = fileparts(video_dir);
save(fullfile(intermediate_dir, ['spinfo_' video_name]), 'sp');

end