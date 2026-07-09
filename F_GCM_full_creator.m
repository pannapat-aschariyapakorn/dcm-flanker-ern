% Set folder
loadfolder = 'individual_model';
savefolder = loadfolder;
excluded_subjects = [8, 18];
target_model = 'M_2-4-1-3';

GCM = {};

for subject = 1:29
    if ismember(subject, excluded_subjects)
        continue;
    end
    dir = sprintf('./dcm_analysis/%s/DCM_%s-Flanker-sub%s_incorrect_avg.mat', ...
        loadfolder, target_model, sprintf('%0*d',(subject<0)+2,subject));
    if ~exist(dir, 'file')
        warning('%s NOT EXISTED!!', dir);
        continue;
    end
    dcm = load(dir);
    GCM{end+1, 1} = dcm.DCM;
end


if ~exist(sprintf('./peb_analysis/%s', savefolder), 'dir')
    mkdir(sprintf('./peb_analysis/%s', savefolder));
end

save(sprintf('./peb_analysis/%s/GCM_full.mat', savefolder), 'GCM');