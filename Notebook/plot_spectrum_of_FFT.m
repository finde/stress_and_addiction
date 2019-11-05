function [f, P1] = plot_spectrum_of_FFT(Y, L, Fs, title_txt)
%
% plot_spectrum_of_FFT (s_Y, s_L, title_txt)
% 
% Y  = spectrum vector
% L  = signal length
% Fs = sampling frequency
% title_txt = plot title
% f  = frequency range
% P1 = normalized Spectrum

    P2 = abs(Y/L);                      % signal below 0 is difficult to compute (imaginary)
    P1 = P2(1:L/2+1);                    % and since it is a mirror, we can take only half
    P1(2:end-1) = 2*P1(2:end-1);        % and double it to compensate

    f = Fs*(0:(L/2))/L;
    plot(f, P1) 
    title(title_txt)
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
end