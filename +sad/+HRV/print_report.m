function print_report(hrvResult) 
    fprintf('\n');
    fprintf('\t\tBPM : %.3f\n', hrvResult.BPM);
    fprintf('\t\tAVNN : %.3f\n', hrvResult.AVNN);
    fprintf('\t\tSDNN : %.3f\n', hrvResult.SDNN);
    fprintf('\t\tRMSSD : %.3f\n', hrvResult.RMSSD);
    fprintf('\t\tSDANN : %.3f\n', hrvResult.SDANN);
    fprintf('\t\tSDNNi : %.3f\n', hrvResult.SDNNi);
end