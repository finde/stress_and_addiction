function [fullpath, output] = sad_main()
    rootDataPath = 'SAD/data_lemon/MRI_PERPHYS_joined:';
    subjectID = 'sub-010003:/ses-01:/func:';
%     filePath = 'sub-010003_ses-01_task-rest_acq-AP_run-01_recording-ecg_physio.tsv';
    filePath = 'short.tsv';
    
    fullpath = fullfile(rootDataPath, subjectID, filePath);
    output = tsvread(fullpath);
    
    plot(output(:,1))
end

