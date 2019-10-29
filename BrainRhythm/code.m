
%% FIRST SECTION: LOAD DATA AND FILTER
EEG_Tap = pop_loadset('TappingContinuous.set');
EEG_EO = pop_loadset('EOContinuous.set');
EEG_Tap = pop_eegfiltnew(EEG_Tap, 8, 13, []);
EEG_EO = pop_eegfiltnew(EEG_EO, 8, 13, []);
%EEG_Tap.data = filter_fir(double(EEG_Tap.data),EEG.srate,8,13,3.0);
%EEG_EO.data = filter_fir(double(EEG_EO.data),EEG.srate,8,13,3.0);

%% SECOND SECTION: Calculate connectivity using different methods
ConnAECTap = AEC(EEG_Tap.data(:,6000:15999)');
ConnSLTap = SyncLL(EEG_Tap.data(:,6000:15999)','reconstruct',[8 13 EEG.srate],'speed',8,'verbose',1);
% correct the diagonal to 1, since SyncLL self-similarity is 100%
ConnSLTap(logical(eye(128))) = 1;
% PLI will have diagnoal of 0, since similarity in phase is always
% 100% for identical, resulting in 0 PLI connectivity which ignores
% in-phase likeness.
ConnPLITap = PLI(EEG_Tap.data(:,:)');

% plotting. YOU MAY WANT TO ADAPT THE SCALING OF THE DOT
cDotScale = 1;
figure; PlotConnectivity_alt(ConnAECTap,EEG_Tap,95, cDotScale, 1, [0 max(ConnAECTap(:))]);
figure; PlotConnectivity_alt(ConnSLTap,EEG_Tap,95, cDotScale, 1, [0 max(ConnSLTap(:))]);
figure; PlotConnectivity_alt(ConnPLITap,EEG_Tap,95, cDotScale, 1, [0 max(ConnPLITap(:))]);

%% Plot connectivity matrix
figure;
subplot(1,3,1); 
imagesc(ConnAECTap); title('AEC connectivity matrix'); ylabel('Electrodes'); xlabel('Electrodes'); set(get(colorbar,'ylabel'),'string','AEC');
subplot(1,3,2); 
imagesc((ConnSLTap).^1); title('SL connectivity matrix'); ylabel('Electrodes'); xlabel('Electrodes'); set(get(colorbar,'ylabel'),'string','SL');
subplot(1,3,3); 
imagesc(ConnPLITap); title('PLI connectivity matrix'); ylabel('Electrodes'); xlabel('Electrodes'); set(get(colorbar,'ylabel'),'string','PLI');

% Are these images tha same or different? What is the correlation between
% these images? Do the results make sense?
corr([sdiag(ConnPLITap)' sdiag(ConnSLTap)', sdiag(ConnAECTap)'])



%% THIRD SECTION: compare between conditions (Tap already done)
ConnPLIEO = PLI(EEG_EO.data(:,:)');

% plot this
PlotConnectivity_alt(ConnPLITap,EEG_Tap, 95, cDotScale, 1, [0 max(ConnPLITap(:))]);
PlotConnectivity_alt(ConnPLIEO,EEG_EO, 95, cDotScale, 1, [0 max(ConnAECTap(:))]);
figure;
subplot(1,3,1); 
imagesc(ConnPLITap); title('Tapping'); ylabel('Electrodes'); xlabel('Electrodes'); set(get(colorbar,'ylabel'),'string','PLI');
subplot(1,3,2); 
imagesc(ConnPLIEO); title('EO'); ylabel('Electrodes'); xlabel('Electrodes'); set(get(colorbar,'ylabel'),'string','PLI');
subplot(1,3,3); 
imagesc(ConnPLITap-ConnPLIEO); title('Tap - EO'); ylabel('Electrodes'); xlabel('Electrodes'); set(get(colorbar,'ylabel'),'string','{\Delta}PLI');

% what do these images tell you?

% Save of the connectivity matrices
save('Connectivity.mat','Conn*')






%% FOURTH SECTION: TF analysis of the tapping data

% NOTE the tapping experiment is a very simple experiment. Subjects get to
% view a blinking dot (at precisely 1 Hz = 1 Sec interval). They follw the
% onset of the dot by tapping the keyboard. This keypress is recorded as
% well as their EEG. After a short entrainment period the dot disappears
% and subjects continue self-paced for minutes on end.

% load the data again, with ICA decomposition.
EEG_Tap = pop_loadset('TappingContinuous.set');

% The motor areas produce a lot of beta activity in steering the muscles.
% This beta activity should therefore show a string 1 Hz modulation. Let's
% see if that is the case...

% cut into epochs selecting 1.4 seconds before the tapping events and 1.4 s
% after. These are called epochs. We will extract the power of many
% frequencies as a function of time within this epoch. These power values
% are avreraged over epochs. Only SYSTEMATIC power increasses/decreases
% will then remain. Ongoing fluctuations that have nothing to do with
% finger tapping will disappear.

% cut into epochs
EEG_TapEpoch = pop_epoch(EEG_Tap, {'1'}, [-1.4   1.4], 'newname', 'BDF file resampled pruned with ICA epochs', 'epochinfo', 'yes');
EEG_TapEpoch = eeg_checkset(EEG_TapEpoch);

% INSPECT THE COMPONENTS. Which are over motor cortices and possibly
% involved in steering the finger tapping?
EEG=EEG_TapEpoch;
pop_selectcomps(EEG, [1:15]);


% plot into a figure the TF transform using the EEGLAB pop_newtimef
% function. PLT ICs number 9 and 14
figure; 

subplot(2,1,1)
pop_newtimef( EEG_TapEpoch, 0, 9, [-1398  1391], [2 0.5] , 'topovec', ...
EEG.icawinv(:,9), 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', ...
['IC 9'], 'baseline',[0], 'plotphase', 'off', 'plotitc','off', 'padratio', 2);
subplot(2,1,2)
pop_newtimef( EEG_TapEpoch, 0, 14, [-1398  1391], [2 0.5] , 'topovec', ...
EEG.icawinv(:,14), 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', ...
['IC 14'], 'baseline',[0], 'plotphase', 'off', 'plotitc','off', 'padratio', 2);

% First plot the source level connectivity network for ICs 1, 9 and 14.
% These are suspected to serve specific functions, related or unrelated to
% the motor activity. Which do you suspect are connected, and which not?
act_cont = icaact(EEG_Tap.data,EEG_Tap.icaweights*EEG_Tap.icasphere);
act_cont = filter_fir(act_cont,EEG_Tap.srate,11,25,3);
actAEC = AEC(act_cont([1:14],:)');
actPLI = PLI(act_cont([1:14],:)');
actPTE = PTE(act_cont([1:14],:)',4);
figure;
subplot(1,3,1); imagesc(actAEC,[0 max(sdiag(actAEC))]); colorbar;
subplot(1,3,2); imagesc(actPLI,[0 max(sdiag(actPLI))]); colorbar;
subplot(1,3,3); imagesc(actPTE,minmax(sdiag(actPTE))); colorbar;

% Were interested in high alpha/beta activity only. Filter the data & recalculate the IC
% activations (=source signals) within these frequencies. This removes
% unwanted activity. The TF plots gave you an indication of what
% frequencies are interesting.
frqlo = 10;
frqhi = 30;
EEG_TapEpoch = pop_eegfiltnew(EEG_TapEpoch, frqlo, frqhi, []);
Times = EEG_TapEpoch.times;

% Calculate the IC activations from the filtered data. In epochs!
act_epoch = icaact(EEG_TapEpoch.data,EEG_TapEpoch.icaweights*EEG_TapEpoch.icasphere);
act_epoch = reshape(act_epoch,[70 358 397]);

% now the data are ready to do a connectivity analysis between separate
% components. You could argue that volume conduction plays no role anymore.



%% Source level connectivity 

% Input: epochs of independent component activations (source level
% signals). Calculate the change of connectivity over time in 20 sample
% wide blocks within the epoch.



% Compare component 14 (right motor) to the 13 components before it (the
% 'major' components. First filter the activation (source signals) into 

figure;
hold on;
p=[];              % p will hold the connectivity between comps 1:13 evolving over time
for comp1=1:13     % componnets to compare with n. 14
    count=0;       % a counter
    for s=1:10:size(act_epoch,2)-49             % this is the time parameter (s=sample) 
        count=count+1;                    % up the counter
        temp = act_epoch([comp1 14],s:s+39,:);  % extract the data, use temp(:,:) to concatenate
        % t=SyncLL(temp(:,:)','reconstruct',[frqlo frqhi EEG_TapEpoch.srate],'speed',32); 
        t=AEC(temp(:,:)');   
        p(comp1,count)=t(2,1);                % store in the p matrix
        tt(count) = mean(Times(s:s+39))./1000;
    end
    plot(tt,p(comp1,:),'.-','color',rand(3,1));  % use a random color
end
% create a legend
for l=1:13,
    leg{l}=sprintf('%d with 14\n',l); 
end; 
legend(leg)