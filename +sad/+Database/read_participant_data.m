function ecgWaveformData = read_participant_data(SADParams, participantID)
% 
% sad__read_participant_data(participantID)
% 
% participantID : participant's unique ID (e.g 'sub-010003')
%
fprintf('\n\n------------------------------------------\n');
fprintf('\n-= Reading ID: %s =-\n',participantID);

% default variable, which should later converted to nargin
rootDataPath = SADParams.cachedata;
sessID = SADParams.sessID;

subjectDir = strcat(participantID, '/', sessID, '/func/');
filePath = strcat(participantID, '_', sessID,'_task-rest_acq-AP_run-01_recording-ecg_physio.tsv');
URLfile = strcat(SADParams.mainURL, '/Continuous_Peripheral_Physiology_During_MRI_MPILMBB_LEMON/MRI_PERPHYS_joined/', ...
                    subjectDir, filePath, '.gz');

Fs = 1000; % frequency per second

isPlottingWaveform = 0;

% time_window = (5*60);
time_window = 'all';
fullpath = fullfile(rootDataPath, filePath);
zippath = fullfile(rootDataPath, strcat(filePath,'.gz'));
cacheFilePath=strrep(fullpath,'.tsv','_all.mat');

if time_window ~= 'all'
    range = 1:1:(time_window*Fs);
    cacheFilePath=strrep(fullpath,'.tsv', strcat('_', num2str(time_window),'.mat'));  
end

if ~isfile(fullpath)
    if ~isfile(zippath)
        disp("download zip file ...")
        try
            websave(zippath, URLfile);
        catch
            fprintf('%s does not have ecg file', participantID)
            ecgWaveformData = [];
        end
    end
    
    if isfile(zippath)
        disp("extracting compressed file ...")
        try
            gunzip(zippath);
        catch
            fprintf('%s unzip error', participantID)
            ecgWaveformData = [];
        end
    end
end

if isfile(fullpath)
    fprintf('  > loading ...')
    
    % read tsv (check cache if exists)
    if isfile(cacheFilePath)
        loadedData = load(cacheFilePath);
        if isfield(loadedData, 'ecgWaveformData')
            ecgWaveformData = loadedData.ecgWaveformData;
        else
            ecgWaveformData = loadedData.ecgData;
        end
    else
    
        if time_window ~= 'all'
            [output, header, raw] = sad.File.tsvread(fullpath, range);
        else
            [output, header, raw] = sad.File.tsvread(fullpath, '1:1:end');
        end

        % clean up NaN rows
        fprintf('  > cleaning ...')
        output(sum(isnan(output), 2) == size(output, 2), :) = [];
        
        ecgWaveformData = output(:,1);
        save(cacheFilePath, 'ecgWaveformData');
    end

    if isPlottingWaveform == 1
        fprintf('  > plotting ...')
        sad.Visualization.plot_ecg_waveform(ecgData, range);
    end
    
    fprintf('  > done ...')
else
    fprintf('  > FILE NOT FOUND at ')
    disp(fullpath)
end

end