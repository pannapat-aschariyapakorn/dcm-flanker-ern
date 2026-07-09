loadfolder = 'model_comparison_template';
savefolder = 'individual_model';
target_model = 'M_2-4-1-3';

GCM_templates = {};
dir = sprintf('./peb_analysis/%s/%s.mat', ...
    loadfolder, target_model);
if ~exist(dir, 'file')
    warning('%s NOT EXISTED!!', dir);
end
dcm_template = load(dir);
dcm_template = dcm_template.DCM;
for i = 1:6
    dcm = dcm_template;
    switch i
        case {1, 2}
            dcm.B{1,1} = dcm.A{1, i};
        case 3
            dcm.B{1,1} = eye(7);
        case 4
            dcm.B{1,1} = dcm.A{1,1} | dcm.A{1,2};
        case 5
            dcm.B{1,1} = dcm.A{1,1} | dcm.A{1,2} | eye(7);
        case 6
            dcm.B{1,1} = zeros(7);
    end
    GCM_templates{end+1, 1} = dcm;
end


if ~exist(sprintf('./peb_analysis/%s', savefolder), 'dir')
    mkdir(sprintf('./peb_analysis/%s', savefolder));
end

save(sprintf('./peb_analysis/%s/GCM_templates.mat', savefolder), 'GCM_templates');