function save_data(SADParams)
%EXPORT Save preselected metadata
    data_file = fullfile(SADParams.readdata, 'data.mat');
    data=SADParams.data;
    save(data_file, 'data');

    if sum(isfield(SADParams, 'results')) > 0
        results_file = fullfile(SADParams.writedata, 'results.mat');
        results = SADParams.results;
        save(results_file, 'results');
    end
    
    if sum(isfield(SADParams, 'completedAnnotation')) > 0
        annotation_file = fullfile(SADParams.writedata, 'annotation.mat');
        annotated = SADParams.completedAnnotation;
        save(annotation_file, 'annotated');
    end
    
end

