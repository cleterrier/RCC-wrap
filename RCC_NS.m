function RCC_NS(NSpath, segpara, imsize, pixelsize, binsize, rmax)

%% Typical
% RCC_NS2(filepath, 4000, 256, 160, 30, 0.2);

%% input NSTORM tab-delimited text file
[NSparent, NSname, NSext] = fileparts(NSpath);
delimiterIn = '\t';
headerlinesIn = 1;
A = importdata(NSpath,delimiterIn,headerlinesIn);

%% build input coordinates (using warped Xw and Yw coordinates)
coords = [A.data(:,20)/pixelsize A.data(:,21)/pixelsize A.data(:,12)];

%% Run RCC on coordinates
[coordscorr, finaldrift, ~,~] = RCC(coords, segpara, imsize, pixelsize, binsize, rmax);
finalcoor = coordscorr * pixelsize;

% assign channels text column
Channels = A.textdata(2:end, 1);

% Assign corrected coordinates to both Xc/Yc (unwarped) and Xwc/Ywc
% (warped). Attention! Xc and Yc are obtained from warped coordinates not
% raw X and Y. Could process separately warped and unwarped but would be 2X
% slower
A.data(:,3) = finalcoor(:,1);
A.data(:,4) = finalcoor(:,2);
A.data(:,22) = finalcoor(:,1);
A.data(:,23) = finalcoor(:,2);

%% Make output path
NSpathout = strcat(NSparent, filesep, NSname, '_RCC', NSext);
disp(['Processed ' NSname ', saving to ' NSpathout]);

%% Write NS tab-delimited text file line by line
fid = fopen(NSpathout, 'w');
Header = strjoin(A.textdata(1,:), delimiterIn);
fprintf(fid, '%s\n', Header);
formatSpec = '%s\t%7.1f\t%7.1f\t%7.1f\t%7.1f\t%11.5f\t%11.5f\t%11.5f\t%11.5f\t%11.5f\t%11.5f\t%11.5f\t%d\t%d\t%d\t%d\t%3.0f\t%3.0f\t%11.5f\t%11.5f\t%7.1f\t%7.1f\t%7.1f\t%7.1f\n';
for k = 1:size(A.data, 1);
fprintf(fid, formatSpec, Channels{k}, A.data(k,:));
end
fclose(fid);

end