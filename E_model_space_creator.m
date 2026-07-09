dcm_dir = 'D:\Thesis\COG_BCI\Flanker_ERN_rerun\dcm_analysis\individual_model\';
excluded_subjects = [8, 18];

model_template = repmat(struct('fname', [], 'F', [], 'Ep', [], 'Cp', []), 1, 24);
subj(1, 27) = struct('sess', []);

for subject = 1:27
    %if ismember(subject, excluded_subjects)
        %continue;
    %end
    subj(subject).sess = struct('model', []);
    subj(subject).sess.model = model_template;
end

subject_to_include = 1:29;
subject_to_include = subject_to_include(~ismember(subject_to_include, excluded_subjects));
model_names = load("model_names.mat").filenames;
for i = 1:size(subject_to_include,2)
    subject = subject_to_include(i);
    for j = 1:24
        model_name = model_names{j};
        filename = sprintf('Flanker-sub%s_incorrect_avg', sprintf('%0*d',(subject<0)+2,subject));
        filename = sprintf('DCM_%s-%s', model_name, filename);
        filefulldir = sprintf('%s%s',dcm_dir,filename);
        DCM = load(sprintf('%s.mat', filefulldir)).DCM;
        subj(i).sess.model(j).fname = filefulldir;
        subj(i).sess.model(j).F   = DCM.F;
        subj(i).sess.model(j).Ep  = DCM.Ep;
        subj(i).sess.model(j).Cp  = DCM.Cp;
    end
end
save('model_space.mat', 'subj');