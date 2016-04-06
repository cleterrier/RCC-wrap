function RCC_TS_batch(segpara, imsize, pixelsize, binsize, rmax)

%% Typical
% RCC_TS_batch(1000, 256, 160, 30, 0.2);

dirpath = uigetdir;

FileList = dir(fullfile(dirpath,'*.csv'));   %# list all *.csv files
N = size(FileList,1);

[parentdir, currentdir, ~] = fileparts(dirpath);


if length(currentdir) == 0 % case for OSX (trailing separator)
    [parentdir, parentname, ~] = fileparts(parentdir);
    parentdir = [parentdir filesep];
    mkdir(parentdir, [parentname ' RCC' filesep]);
    outdir = [parentdir parentname ' RCC'];
else % case for Windows (untested)
    mkdir(parentdir, [currentdir ' RCC']);
    outdir = [parentdir filesep currentdir ' RCC'];
end

disp(['Output folder: ' outdir]);

for k = 1:N

    %% get the file name and build path
    filename = FileList(k).name;
    disp(['Processing file #' num2str(k) '/' num2str(N) ': ' filename]);
    TSpath = fullfile(dirpath, filename); 
    
    %% Open TS file
    [~,TSname, TSext] = fileparts(TSpath);
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
    TSpathout = strcat(outdir, filesep, outname, TSext);
    fid = fopen(TSpathout, 'w');
    fprintf(fid, '%s\n', headerline);
    fclose(fid);

    TSfileout = TSfile;
    TSfileout(:, 1) = coordscorr(:, 3);
    TSfileout(:, 2:3) = coordscorr(:, 1:2) * pixelsize;
    dlmwrite(TSpathout, TSfileout, '-append', 'delimiter', ',');


end



end