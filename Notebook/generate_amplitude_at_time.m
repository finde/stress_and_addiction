function a = generate_amplitude_at_time(Fc, tv)
% 
% generate_amplitude_at_time(Frequency, time_vector)
% 
% Fc : signal's frequency
% tv : time vector
%
    a = cos(2*pi*Fc*tv);
end