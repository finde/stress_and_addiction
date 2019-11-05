function t = generate_sampling_time(Fs,StopTime)
% 
% generate_sampling_time(Fs, StopTime)
% 
% Fs       : sample per second
% StopTime : time limit of the samples
%
    dt = 1/Fs;                   % seconds per sample
    t = (0:dt:StopTime-dt)';     % seconds
end