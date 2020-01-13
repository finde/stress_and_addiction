function hrv = time_domain_analysis(SADParams, ecgData, subID, gr, annotate_mode)
%%%
% SDNN	ms	                 Standard deviation of NN intervals
% SDANN	ms	                 Standard deviation of the average NN intervals for each 5 min segment of a 24 h HRV recording
% SDNN index (SDNNI)	ms	 Mean of the standard deviations of all the NN intervals for each 5 min segment of a 24 h HRV recording
% pNN50	%	                 Percentage of successive RR intervals that differ by more than 50 ms
% HR Max − HR Min	bpm	 Average difference between the highest and lowest heart rates during each respiratory cycle
% RMSSD	ms	                 Root mean square of successive RR interval differences
%
    hrv.ID = subID;
    
    annFig = [];
        
    Fs = SADParams.Fs;
    
    rootDataPath = SADParams.cachedata;
    
    filePath = strcat(subID, '_', SADParams.sessID,'_task-rest_acq-AP_run-01_recording-ecg_physio_rpeaks.mat');
    cacheFilePath = fullfile(rootDataPath, filePath);
    
    annotFilePath = strcat(subID, '_', SADParams.sessID,'_temp.mat');
    annotationCachePath = fullfile(rootDataPath, annotFilePath);
    
    r_peaks = [];
    removed_peaks = [];
    last_post = [];
    
    % check if cache has r_peaks
    if isfile(cacheFilePath)
        loadedData = load(cacheFilePath);
        if isfield(loadedData, 'r_peaks')
            r_peaks = loadedData.r_peaks;
        end
    end
    
    if isempty(r_peaks)
        [~,r_peaks,delay]=sad.HRV.pan_tompkin(ecgData,Fs,gr);
    end   
    
    function plot_histogram(xLimData, yLimData)
        disp(length(r_peaks))
        
        clf(annFig)
        hold on;
        sad.Visualization.plot_ecg_waveform(ecgData ./ 1000)
        x = r_peaks ./ Fs;
        tx = [x;x;nan(1,length(x))];
        ystart = zeros(1, length(x));
        ystop = ones(1, length(x)) * -1;
        ty = [ystart;ystop;nan(1,length(x))];
        plot(tx(:),ty(:))
        
        if ~isempty(xLimData)
            xlim(xLimData);
        end
            
        if ~isempty(yLimData)
            ylim(yLimData);
        end
        
        title(['RPeaks of ', subID])
        hold off;
    end
    
    function keypressHandler(src, event)
        
       switch event.Key
           
           case 'c'
               if sum(isfield(SADParams, 'completedAnnotation')) == 0
                   SADParams.completedAnnotation = {subID};
               else
                   SADParams.completedAnnotation = unique(horzcat(SADParams.completedAnnotation, {subID}));              
               end
               sad.Database.save_data(SADParams);
               close(annFig)
               
           case 'b'
               brush(annFig)
               
           case 'r' % Remove
               h=findobj(gca,'type','line');
               selIdx=get(h(1),'BrushData');
               xData=h(1).XData(logical(selIdx));
               removed_peaks = r_peaks(ismember(r_peaks, uint32(xData .* Fs)));
               r_peaks = r_peaks(not(ismember(r_peaks, uint32(xData .* Fs))));          
               plot_histogram(annFig.CurrentAxes.XLim, annFig.CurrentAxes.YLim)
               
           case 's'
               % save
               save(cacheFilePath, 'r_peaks');
               last_post = [annFig.CurrentAxes.XLim annFig.CurrentAxes.YLim];
               save(annotationCachePath,'last_post');
       
           case 'u'
               % undo
               if ~isempty(removed_peaks)
                   r_peaks = horzcat(r_peaks, removed_peaks);
                   plot_histogram(annFig.CurrentAxes.XLim, annFig.CurrentAxes.YLim)
               end
               removed_peaks = [];
               
           case 'rightarrow'
               % scroll right
               xLimData = annFig.CurrentAxes.XLim;
               diff = xLimData(2) - xLimData(1) - 0.5;
               xLimData = xLimData + diff;
               if ~isempty(xLimData)
                    xlim(xLimData);
                end

                if ~isempty(annFig.CurrentAxes.YLim)
                    ylim(annFig.CurrentAxes.YLim);
                end
               
           case 'leftarrow'
               % scroll left
               xLimData = annFig.CurrentAxes.XLim;
               diff = xLimData(2) - xLimData(1);
               xLimData = xLimData - diff;
               if xLimData(1) < 0
                   xLimData = xLimData - xLimData(1);
               end
           
                if ~isempty(xLimData)
                    xlim(xLimData);
                end

                if ~isempty(annFig.CurrentAxes.YLim)
                    ylim(annFig.CurrentAxes.YLim);
                end
               
           case 'uparrow'
               % go to initial pos
                xlim([-0.1 12.5]);
                ylim([-1.5 1.5]);
                
           case 'downarrow'
               % load last position
                if isfile(annotationCachePath)
                    loadedData = load(annotationCachePath);
                    if isfield(loadedData, 'last_post')
                        last_post = loadedData.last_post;
                        xlim([last_post(1) last_post(2)]);
                        ylim([last_post(3) last_post(4)]);
                    end
                else
                    disp("NOT ANNOTATED YET")
                end
               
           otherwise
       end
    end
    
    % plot
    if gr == 1 || annotate_mode == 1
        annFig = figure;
        plot_histogram([],[])        
        set(annFig,'KeyPressFcn',@keypressHandler);
        uiwait(annFig);
    end
    
    hrv.BPM = length(r_peaks)/(length(ecgData)/Fs/60);
    RR_interval = r_peaks(2:end) - r_peaks(1:end-1);
    hrv.RR_interval = RR_interval;
    hrv.AVNN = mean(RR_interval);
    hrv.SDNN = std(RR_interval);
    hrv.RMSSD = sqrt(mean(RR_interval.*RR_interval));
    
    window_size = 5*60*Fs;
    bin_of_5_mins = 0:window_size:(ceil(length(ecgData)/window_size)*window_size);
    
    [~, binId] = histc( r_peaks, bin_of_5_mins ) ;
    grouped = accumarray( binId', r_peaks, [], @(v){v} );
    mean_arr = (1: length(grouped));
    std_arr = (1: length(grouped));
    for i = 1: length(grouped)
        r_peaks_in_window = cell2mat(grouped(i));
        rr_intervals_in_window = r_peaks_in_window(2:end) - r_peaks_in_window(1:end-1);
        mean_arr(i) = mean(rr_intervals_in_window);
        std_arr(i) = std(rr_intervals_in_window);
    end
    
    hrv.SDANN = std(mean_arr);
    hrv.SDNNi = mean(std_arr);
end