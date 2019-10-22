function [fullpath, output] = sad_main()
    rootDataPath = 'data_lemon';
    subjectID = 'sub-010003:/ses-01:/func:';
%     filePath = 'sub-010003_ses-01_task-rest_acq-AP_run-01_recording-ecg_physio.tsv';
    filePath = 'short.tsv';
    
    fullpath = fullfile(rootDataPath, subjectID, filePath);
    output = tsvread(fullpath);
    
    plot(output(:,1))
end

