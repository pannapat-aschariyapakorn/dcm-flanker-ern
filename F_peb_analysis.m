folder = 'individual_model';

file_name = 'reaction-time';
target_column = 4;
%}
%{
file_name = 'accuracy';
target_column = 6;
%}

% Load GCM
GCM = load(sprintf('./peb_analysis/%s/GCM_full.mat', folder));
GCM = GCM.GCM;

% Load design matrix
design_matrix = load(sprintf('./peb_analysis/%s/design_matrix.mat', folder));
design_matrix = design_matrix.design_matrix;
target_design_matrix = design_matrix(:, [1, target_column]);
Xnames = {'Mean', 'Subject', 'Reaction time (congruent)', 'Reaction time (incongruent)', 'Accuracy (congruent)', 'Accuracy (incongruent)'};
target_Xnames = Xnames([1, target_column]);

% PEB settings
M = struct();
M.Q = 'all';
M.X = target_design_matrix;
M.Xnames = target_Xnames;

% PEB estimation
%{
[PEB_All, RCM_All] = spm_dcm_peb(GCM, M, {'B'});
save(sprintf('./peb_analysis/%s/PEB_%s.mat', folder, file_name), 'PEB_All', 'RCM_All');
%}
load(sprintf('./peb_analysis/%s/PEB_%s.mat', folder, file_name), 'PEB_All', 'RCM_All');

% Automatic PEB search
%{
[BMA_auto, BMR_auto] = spm_dcm_peb_bmc(PEB_All);
save(sprintf('./peb_analysis/%s/BMA_auto_%s.mat', folder, file_name), 'BMA_auto');
save(sprintf('./peb_analysis/%s/BMR_auto_%s.mat', folder, file_name), 'BMR_auto');
%}

% Specific PEB search
templates = load(sprintf('./peb_analysis/%s/GCM_templates.mat', folder));
templates = templates.GCM_templates;
[BMA_spec, BMR_spec] = spm_dcm_peb_bmc(PEB_All, templates);
save(sprintf('./peb_analysis/%s/BMA_spec_%s.mat', folder, file_name), 'BMA_spec');
save(sprintf('./peb_analysis/%s/BMR_spec_%s.mat', folder, file_name), 'BMR_spec');

spm_dcm_peb_review(BMA_spec, GCM);