function SADparams = InitializeSADparams(project_name)
%InitializeSADparams create project configuration
%
%   settings = InitializeSADparams('project_name')
%
%   OVERVIEW:   
%       This file stores settings and should be configured before
%       each use of the Stress and Addiction Toolbox:
%       1.  Project Specific Input/Output Data type and Folders
%       2.  Debug Settings
%       3.  Preprocess Settings
%       4.  Output Settings 
%       5.  Time of Process and Filename to Save Data
%
%   INPUT:      
%       project_name = a string with the name of the project - this
%       will determine the naming convention of file folders 
%
%   OUTPUT:
%       SADparams - struct of various settings for the sad_toolbox analysis
%
%%
if isempty(project_name)
    project_name = 'my_project';
end

%% 1.  Project Specific Input/Output Data type and Folders
SADparams.readdata = '';          % Specify name for data input folder
SADparams.writedata = '';         % Specify name for data output folder
SADparams.cachedata = '';         % Specify name for data cache folder
SADparams.sessID = 'ses-01';
SADparams.datasource = 'LEMON';      % Specify data source type
SADParams.completedAnnotation = {};
pathCell = regexp(path, pathsep, 'split');

folderList = {'readdata', 'writedata', 'cachedata'};
defaultFolder = {'/Input', '/Results', '/Cache'};
for k1 = 1:length(folderList)  
    if  isempty(SADparams.(folderList{k1}))
        SADparams.(folderList{k1}) = strcat(project_name,defaultFolder{k1});  
    end
    
    folderpath = SADparams.(folderList{k1});
    if ~exist([pwd filesep folderpath], 'dir')
        mkdir(folderpath);          % Create output folder and 
    end
    if ispc  && ~any(strcmpi(folderpath, pathCell)) || ...
            ~any(strcmp(folderpath, pathCell))
        addpath(genpath(folderpath));   % Add folder to search path
    end
end

switch SADparams.datasource
    case 'LEMON'
        mainURL = 'https://ftp.gwdg.de/pub/misc/MPI-Leipzig_Mind-Brain-Body-LEMON';
        
        % Continuous_Peripheral_Physiology_During_MRI_MPILMBB_LEMON
        ParticipantBasicInfo_url = fullfile(mainURL, ...
                                                         'Behavioural_Data_MPILMBB_LEMON', ...
                                                         'META_File_IDs_Age_Gender_Education_Drug_Smoke_SKID_LEMON.csv');
        disp('Checking metadata ...')
        data_file = fullfile(SADparams.readdata, 'data');
        
        options = weboptions('RequestMethod','get','ArrayFormat','csv','ContentType','table');
        if ~isfile([data_file '.mat'])
            disp('...reading from URL')
            data = webread(ParticipantBasicInfo_url, options);
            
            Selected = true(height(data), 1);
            
            % Validate 
            data.Standard_Alcoholunits_Last_28days = str2double(strrep(data.Standard_Alcoholunits_Last_28days,',','.'));
            
            hasAlcoholUnit = data.Standard_Alcoholunits_Last_28days>=0;
            hasAUDIT = data.AUDIT>=0;
            hasAge = ~cellfun(@isempty,data.Age);
            isYoung = cellFilter(data.Age, {'20-25', '25-30', '30-35', '35-40'}); % hardcoded            
            Selected = Selected .* hasAlcoholUnit .* hasAUDIT .* hasAge .* isYoung;
            
            Group = zeros(height(data), 1);            
            data = [table(Selected, Group) data];           
            
            % test SPLIT by age  
            
            %youngIdx = find(cellFilter(data.Age, {'20-25', '25-30'}) .* data.Selected);
            %oldIdx = find(cellFilter(data.Age, {'20-25', '25-30'}, true) .* data.Selected);
            
            %data{:, 'Group'} = 1;
            %data{youngIdx, 'Group'} = 1;
            %data{oldIdx, 'Group'} = 2;
            %data{find(data.AUDIT <= 8 & data.Selected), 'Group'} = 1;
            %data{find(data.AUDIT > 8 & data.Selected), 'Group'} = 2;
            
            %avgAlcohol = median(data{data.Standard_Alcoholunits_Last_28days >=0, 'Standard_Alcoholunits_Last_28days'});
            avgAlcohol = 14;
            data{find(data.Standard_Alcoholunits_Last_28days <= avgAlcohol & data.Selected), 'Group'} = 1;
            data{find(data.Standard_Alcoholunits_Last_28days > avgAlcohol & data.Selected), 'Group'} = 2;
            
            save(data_file, 'data');
        end     
        load(data_file, 'data');
        SADparams.data = data;
        SADparams.mainURL = mainURL;
        SADparams.Fs = 1000;
        
        annotation_file = fullfile(SADparams.writedata, 'annotation.mat');
        if isfile(annotation_file)
            loaded_annotation = load(annotation_file, 'annotated');
            SADparams.completedAnnotation = loaded_annotation.annotated;
        end
        disp('    ...done')
        
    otherwise
        fprintf('Data source "%s"\n is not supported', SADparams.datasource)
end

function outArg = cellFilter(column, groupData, isNegate)

    if nargin < 3
        isNegate = false;
    end

    outArg = cellfun(@(x) ismember(x, groupData), column, 'UniformOutput', 1);

    if isNegate == true
        outArg = ~outArg;
    end




% https://ftp.gwdg.de/pub/misc/MPI-Leipzig_Mind-Brain-Body-LEMON/Continuous_Peripheral_Physiology_During_MRI_MPILMBB_LEMON/
% https://ftp.gwdg.de/pub/misc/MPI-Leipzig_Mind-Brain-Body-LEMON/Behavioural_Data_MPILMBB_LEMON/Emotion_and_Personality_Test_Battery_LEMON/