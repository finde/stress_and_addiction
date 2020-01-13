function [genderInfo, ageInfo, alcoholInfo, auditInfo] =report(SADParams, selections, drawPlot)
%REPORT Creating statistical report for data distribution of selected participant(s)
%
%   Detailed explanation goes here

% disp(SADParams);

data=SADParams.data;
selected_data=[];
if nargin < 3
    drawPlot = false;
end

if nargin < 2 || isempty(selections)
    fprintf('Generating report for selected participants ...\n')
    selected_data=data(data.Selected==true,:);
else
    fprintf('Generating report for %d participants ...\n', length(selections))
    selected_data=data(contains(data.ID, selections),:);
end

%  find(contains(data.ID, 'sub-XXX'))               % find index of 'sub-XXX'

%% Gender Distribution
genderInfo=categorical(selected_data.Gender_1_female_2_male, [1, 2], [{'Female'},{'Male'}]);

%% Age Distribution
ageInfo = {};
ageInfo.data = categorical(selected_data.Age); 
ageInfo.category = unique(categorical(data.Age));
ageInfo.data0 = categorical(selected_data{selected_data.Group == 0, 'Age'});
ageInfo.data1 = categorical(selected_data{selected_data.Group == 1, 'Age'});
ageInfo.data2 = categorical(selected_data{selected_data.Group == 2, 'Age'});
    
%% Alcohol Standard Distribution
alc_data = data.Standard_Alcoholunits_Last_28days;
default_alcoholInfo = alc_data; %str2double(strrep(alc_data,',','.'));
selected_alcoholInfo = selected_data.Standard_Alcoholunits_Last_28days; %str2double(strrep(selected_data.Standard_Alcoholunits_Last_28days,',','.'));

selected_alcoholInfo0 = selected_data{selected_data.Group == 0, 'Standard_Alcoholunits_Last_28days'};
selected_alcoholInfo1 = selected_data{selected_data.Group == 1, 'Standard_Alcoholunits_Last_28days'};
selected_alcoholInfo2 = selected_data{selected_data.Group == 2, 'Standard_Alcoholunits_Last_28days'};

bin_size = 5;                                                             % bin every 5 until reach 50
upper_limit = 50; 
catnames = cell(upper_limit/bin_size + 1,1);
catnames{1} = '0';
for i=1:length(catnames)-1
    catnames{i+1} = [num2str((i-1)*bin_size + 1) '-' num2str(i*bin_size)];
end
catnames{length(catnames)} = ['> ' num2str(upper_limit)];
alcoholInfo = {};
alcoholInfo.category = catnames;
alcoholInfo.data = discretize(selected_alcoholInfo, [0 (1:bin_size:upper_limit) max(default_alcoholInfo)], 'categorical', catnames);

alcoholInfo.data0 = discretize(selected_alcoholInfo0, [0 (1:bin_size:upper_limit) max(default_alcoholInfo)], 'categorical', catnames);
alcoholInfo.data1 = discretize(selected_alcoholInfo1, [0 (1:bin_size:upper_limit) max(default_alcoholInfo)], 'categorical', catnames);
alcoholInfo.data2 = discretize(selected_alcoholInfo2, [0 (1:bin_size:upper_limit) max(default_alcoholInfo)], 'categorical', catnames);

alcoholInfo.unknown = sum(isnan(selected_alcoholInfo));

%% AUDIT info
auditInfo = selected_data.AUDIT;
auditInfo0 = selected_data{selected_data.Group == 0, 'AUDIT'};
auditInfo1 = selected_data{selected_data.Group == 1, 'AUDIT'};
auditInfo2 = selected_data{selected_data.Group == 2, 'AUDIT'};

%%


if drawPlot
    close all;
    figure
    subplot(2,2,1);
    pie(genderInfo)
    title('Gender')

    subplot(2,2,2);
    hold on 
    % histogram(ageInfo.data0, ageInfo.category)
    histogram(ageInfo.data1)
    histogram(ageInfo.data2)
    title('Age')

    subplot(2,2,3);
    hold on
    histogram(alcoholInfo.data1);
    histogram(alcoholInfo.data2);
    
    title('Standard Alcohol Unit (Last 28days)')
    xlabel(['unknown = ' num2str(alcoholInfo.unknown)])

    subplot(2,2,4);
    hold on
    histogram(auditInfo1)
    histogram(auditInfo2)
    title('AUDIT')
    xlim([-1 25])

end

