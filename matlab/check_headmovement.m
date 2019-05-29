function [cc, cc_demean, cc_rel] = check_headmovement(subject, sel)

cfg          = [];
if numel(subject) > 1
    if isempty(sel)
        error('There are multiple datasets, provide index.');
    end
    cfg.dataset = subject(sel).dataset;
    cfg.trl     = subject(sel).trl;
else
    cfg.dataset  = subject.dataset;
    cfg.trl      = subject.trl;
end    

cfg.trl(:,1) = cfg.trl(:,1) - 1200; % read in an extra second of data at the beginning
cfg.trl(:,2) = cfg.trl(:,2) + 1200; % read in an extra second of data at the end
cfg.trl(:,3) = -1200;               % update the offset, to account for the padding
cfg.channel  = {'HLC0011','HLC0012','HLC0013', ...
                'HLC0021','HLC0022','HLC0023', ...
                'HLC0031','HLC0032','HLC0033'};
cfg.continuous = 'yes';

% meg
headpos           = ft_preprocessing(cfg); % read in the MEG data

cfg        = [];
cfg.length = 60;
headpos    = ft_redefinetrial(cfg, headpos);

% calculate the mean coil position per trial
ntrials = length(headpos.sampleinfo);
for t = 1:ntrials
    coil1(:,t) = [mean(headpos.trial{1,t}(1,:)); mean(headpos.trial{1,t}(2,:)); mean(headpos.trial{1,t}(3,:))];
    coil2(:,t) = [mean(headpos.trial{1,t}(4,:)); mean(headpos.trial{1,t}(5,:)); mean(headpos.trial{1,t}(6,:))];
    coil3(:,t) = [mean(headpos.trial{1,t}(7,:)); mean(headpos.trial{1,t}(8,:)); mean(headpos.trial{1,t}(9,:))];
end
 
% calculate the headposition and orientation per trial (for function see bottom page) 
cc = circumcenter(coil1, coil2, coil3);

% Now you can plot the head position relative to the first value, and compute the maximal position change.
cc_rel    = cc - [repmat(cc(:,1),1,size(cc,2))];
cc_demean = cc - mean(cc, 2);

[maxposchange, indx] = max(abs(cc_rel(:,1:3)*1000)); % in mm
display(maxposchange)
%save(fullfile(savedir, sprintf('%s', subject.name)), 'headpos', 'cc', 'maxposchange');

% plot translations
% figure(); 
% plot(cc_rel(:,1:3)*1000, '--o') % in mm
% title(sprintf('Translations (%s)', subject.name));
% %text(indx(:), maxposchange(:), num2str(maxposchange(:)));
% xlabel('time (min)')
% ylabel('distance (mm)')
% legend('x', 'y', 'z');
% set(gcf, 'Name', sprintf('Translations %s', subject.name), 'NumberTitle', 'off')
%saveas(gcf, fullfile(savedir, sprintf('%s_trans', subject.name)), 'jpg');
%saveas(gcf, fullfile(savedir, sprintf('%s_trans', subject.name)), 'fig');
% plot rotations
% figure(); 
% plot(cc_rel(:,4:6), '--o');
% title(sprintf('Rotations (%s)', subject.name))
% xlabel('time (min)')
% ylabel('angle (deg)')
% legend('x', 'y', 'z');
% set(gcf, 'Name', sprintf('Rotations %s', subject.name), 'NumberTitle', 'off')
%saveas(gcf, fullfile(savedir, sprintf('%s_rot', subject.name)), 'jpg');
%saveas(gcf, fullfile(savedir, sprintf('%s_rot', subject.name)), 'fig');


function [cc] = circumcenter(coil1, coil2, coil3)
 
% CIRCUMCENTER determines the position and orientation of the circumcenter
% of the three fiducial markers (MEG headposition coils). 
%
% Input: X,y,z-coordinates of the 3 coils [3 X N],[3 X N],[3 X N] where N
% is timesamples/trials.
%
% Output: X,y,z-coordinates of the circumcenter [1-3 X N], and the 
% orientations to the x,y,z-axes [4-6 X N].
%
% A. Stolk, 2012
 
% number of timesamples/trials
N = size(coil1,2);
 
%% x-, y-, and z-coordinates of the circumcenter
% use coordinates relative to point `a' of the triangle
xba = coil2(1,:) - coil1(1,:);
yba = coil2(2,:) - coil1(2,:);
zba = coil2(3,:) - coil1(3,:);
xca = coil3(1,:) - coil1(1,:);
yca = coil3(2,:) - coil1(2,:);
zca = coil3(3,:) - coil1(3,:);
 
% squares of lengths of the edges incident to `a'
balength = xba .* xba + yba .* yba + zba .* zba;
calength = xca .* xca + yca .* yca + zca .* zca;
 
% cross product of these edges
xcrossbc = yba .* zca - yca .* zba;
ycrossbc = zba .* xca - zca .* xba;
zcrossbc = xba .* yca - xca .* yba;
 
% calculate the denominator of the formulae
denominator = 0.5 ./ (xcrossbc .* xcrossbc + ycrossbc .* ycrossbc + zcrossbc .* zcrossbc);
 
% calculate offset (from `a') of circumcenter
xcirca = ((balength .* yca - calength .* yba) .* zcrossbc - (balength .* zca - calength .* zba) .* ycrossbc) .* denominator;
ycirca = ((balength .* zca - calength .* zba) .* xcrossbc - (balength .* xca - calength .* xba) .* zcrossbc) .* denominator;
zcirca = ((balength .* xca - calength .* xba) .* ycrossbc - (balength .* yca - calength .* yba) .* xcrossbc) .* denominator;
 
cc(1,:) = xcirca + coil1(1,:);
cc(2,:) = ycirca + coil1(2,:);
cc(3,:) = zcirca + coil1(3,:);
 
%% orientation of the circumcenter with respect to the x-, y-, and z-axis
% coordinates
v = [cc(1,:)', cc(2,:)', cc(3,:)'];
vx = [zeros(1,N)', cc(2,:)', cc(3,:)']; % on the x-axis
vy = [cc(1,:)', zeros(1,N)', cc(3,:)']; % on the y-axis
vz = [cc(1,:)', cc(2,:)', zeros(1,N)']; % on the z-axis
 
for j = 1:N
  % find the angles of two vectors opposing the axes
  thetax(j) = acos(dot(v(j,:),vx(j,:))/(norm(v(j,:))*norm(vx(j,:))));
  thetay(j) = acos(dot(v(j,:),vy(j,:))/(norm(v(j,:))*norm(vy(j,:))));
  thetaz(j) = acos(dot(v(j,:),vz(j,:))/(norm(v(j,:))*norm(vz(j,:))));
 
  % convert to degrees
  cc(4,j) = (thetax(j) * (180/pi));
  cc(5,j) = (thetay(j) * (180/pi));
  cc(6,j) = (thetaz(j) * (180/pi));
end
end
end