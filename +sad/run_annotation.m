%% Init Params and mat files
params = sad.InitializeSADparams('Experiment_1');

%% Prepare Groups
selected_data=params.data(params.data.Selected==true,:);
group_1 = selected_data{selected_data.Group == 1, 'ID'};
group_2 = selected_data{selected_data.Group == 2, 'ID'};

%% (Down)load ecg data and compute HRV
status = zeros(1, numel(group_1));
MINIMUM_DATASET_LENGTH = 900000; % 15 minutes
Result_1 = table();
for n = 1:numel(group_1)
    if sum(isfield(params, 'completedAnnotation')) > 0 && ismember(params.completedAnnotation, group_1{n})
        continue
    end
    
    x = sad.Database.read_participant_data(params, group_1{n});
    if length(x)>=MINIMUM_DATASET_LENGTH
        status(n) = 1;  
        hrv_result = sad.HRV.time_domain_analysis(params, x(1:MINIMUM_DATASET_LENGTH), group_1{n}, 0, 1);
        rtable = struct2table(hrv_result);
        rtable(:,'RR_interval') = [];
        Result_1 = [Result_1; rtable];
        sad.HRV.print_report(hrv_result)
    end
end
x_1 = find(ismember(params.data.ID , group_1(status==0)));

status = zeros(1, numel(group_2));
Result_2 = table();
for n = 1:numel(group_2)
    if sum(isfield(params, 'completedAnnotation')) && ismember(params.completedAnnotation, group_2{n})
        continue
    end
    
    x = sad.Database.read_participant_data(params, group_2{n});
    if length(x)>=MINIMUM_DATASET_LENGTH
        status(n) = 1;
        hrv_result = sad.HRV.time_domain_analysis(params, x(1:MINIMUM_DATASET_LENGTH), group_2{n}, 0, 1);
        rtable = struct2table(hrv_result);
        rtable(:,'RR_interval') = [];
        Result_2 = [Result_2; rtable];
        sad.HRV.print_report(hrv_result)
    end
end
x_2 = find(ismember(params.data.ID , group_2(status==0)));

% Remove invalid participant from Group
x = [x_1', x_2'];
params.data{x,'Group'} = -1 * params.data{x,'Group'};

%% Save
params.results = {Result_1, Result_2};
sad.Database.save_data(params);


%% Report
% todo


%% Test
