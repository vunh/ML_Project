% This function is for computing medians and motion histograms of superpixels
% in an image

function [median_list, histogram_list] = getMotionInformation (spmap, opticalflow, option)

%nbins = option.nbins;
%motion_range = option.motion_range;
%bin_motion = motion_range(1):(motion_range(2)-motion_range(1))/nbins:motion_range(2);

nbins_ang = option.nbins_ang;
nbins_mag = option.nbins_mag;
angle_range = option.angle_range;
magnitude_range = option.magnitude_range;
bin_ang = angle_range(1):(angle_range(2)-angle_range(1))/nbins_ang:angle_range(2);
bin_mag = magnitude_range(1):(magnitude_range(2)-magnitude_range(1))/nbins_mag:magnitude_range(2);

max_sp_ids = length(unique(spmap));
median_list = zeros(max_sp_ids, 1);
histogram_list = zeros(max_sp_ids, nbins_ang);

of_u = opticalflow.u; of_u = of_u(:);
of_v = opticalflow.v; of_v = of_v(:);

for i = 1:max_sp_ids
    idx = find(spmap(:) == i);
    %median_list(i,:) = [median(of_v(idx)), median(of_u(idx))];
    vect = [of_v(idx), of_u(idx)];
    [ang, mag] = convertToAngle(vect);
    %median_list(i,:) = [median(ang), median(mag)];
    median_list(i,:) = [median(ang)];
    %[N_u,~] = histcounts(of_u(idx), bin_motion);
    %[N_v,~] = histcounts(of_v(idx), bin_motion);
    %histogram_list(i, :, 1) = N_u;
    %histogram_list(i, :, 2) = N_v;
    
    [N_ang,~] = histcounts(ang, bin_ang);
    [N_mag,~] = histcounts(mag, bin_mag);
    %histogram_list(i, :) = [N_ang N_mag];
    histogram_list(i, :) = [N_ang];
end

temp = sum(histogram_list,2);
temp = repmat(temp, 1, nbins_ang);
histogram_list = histogram_list ./ temp;

a=3;

end

function [ang, mag] = convertToAngle(vect)

[ang,mag] = cart2pol(vect(:,2), vect(:,1));

end


