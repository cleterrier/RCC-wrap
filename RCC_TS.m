function finaldrift = RCC_TS(TSpath, segpara, imsize, pixelsize, binsize, rmax)

%% Typical
%finaldrift = RCC_TS(filepath, 1000, 256, 160, 30, 0.2);

%% input TS csv file
% TSarg = strcat('wc -l', ' "', TSpath, '"');
% [~, nol] = system(TSarg);
% nol = str2num(strtok(nol));
% col = dlmread(TSpath, ',', [ 1 0 nol-1 0 ] );

[TSparent,TSname, TSext] = fileparts(TSpath);
fid = fopen(TSpath);
headerline = fgetl(fid);
fclose(fid);
TSfile = csvread(TSpath, 1, 0);

%% build input coordinates
colframes = TSfile(:,1);
colXp = TSfile(:,2) / pixelsize;
colYp = TSfile(:,3) / pixelsize;

coords = [colXp colYp colframes];

%% Run RCC on coordinates
[coordscorr, finaldrift, ~,~] = RCC(coords, segpara, imsize, pixelsize, binsize, rmax);

%% output TS csv file
outname = strrep(TSname, 'K_TS', 'K_RCC_TS');
TSpathout = strcat(TSparent, filesep, outname, TSext);
fid = fopen(TSpathout, 'w');
fprintf(fid, '%s\n', headerline);
fclose(fid);

TSfileout = TSfile;
TSfileout(:, 1) = coordscorr(:, 3);
TSfileout(:, 2:3) = coordscorr(:, 1:2) * pixelsize;
dlmwrite(TSpathout, TSfileout, '-append', 'delimiter', ',');

end