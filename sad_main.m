function [fullpath, output] = sad_main(participantID, range)
% Preparation:
%   - Go stress_and_addition folder, then run the code below
%
% Example:
%   sad_main('sub-010003','1:1000:end')
%
% ToDo: 
%   - Check HRV code
%   - Smart tsv reading (for large data)

    % default values
    rootDataPath = 'data_lemon';
    subjectID = strcat(participantID, ':/ses-01:/func:');
    filePath = strcat(participantID, '_ses-01_task-rest_acq-AP_run-01_recording-ecg_physio.tsv');
    
    fullpath = fullfile(rootDataPath, subjectID, filePath);
    
    % read tsv
    [output, header, raw] = tsvread(fullpath, range);
 
    % clean up NaN rows
    output(sum(isnan(output), 2) == size(output, 2), :) = [];
    
    plot(output(:,1))
    ylim([-1000,1000]);
    
end

