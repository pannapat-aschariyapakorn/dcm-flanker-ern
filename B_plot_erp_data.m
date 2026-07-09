epochs_cong = {};
epochs_incong = {};
epochs_cong_correct = {};
epochs_cong_incorrect = {};
epochs_incong_correct = {};
epochs_incong_incorrect = {};
epochs = {};

savedir = './preprocessed_data/preprocessed_data_new_200to0';
% erp_save_dir = sprintf('%s_for_erp_plot', savedir);

time_window =  [-0.2  0.8];

shift = 0; % in seconds

% Plot cong vs incong, correct vs incorrect

for session = 1:3
    for subject = 1:29
    
        filename = 'Flanker.set';
        filename = sprintf('%s_sub-%s_ses-S%d', filename, sprintf('%0*d',(subject<0)+2,subject), session);
        filename_before_epoch = append(filename, '_before_epoch.set');
        EEG.etc.eeglabvers = '2024.2';
        
        EEG_cong = pop_loadset(append(filename, '_cong.set'), savedir);
        epochs_cong{end+1} = EEG_cong;
        EEG_incong = pop_loadset(append(filename, '_incong.set'), savedir);
        epochs_incong{end+1} = EEG_incong;
        EEG = pop_loadset(append(filename, '_epoched.set'), savedir);
        epochs{end+1} = EEG;

        % Separating cong vs incong + correct vs incorrect
        try
            EEG_cong_correct = pop_loadset(append(filename, '_cong_correct.set'), savedir);
            epochs_cong_correct{end+1} = EEG_cong_correct;
        catch E
            warning("Unable to pop events");
        end

        try
            EEG_cong_incorrect = pop_loadset(append(filename, '_cong_incorrect.set'), savedir);
            epochs_cong_incorrect{end+1} = EEG_cong_incorrect;
        catch E
            warning("Unable to pop events");
        end

        try
            EEG_incong_correct = pop_loadset(append(filename, '_incong_correct.set'), savedir);
            epochs_incong_correct{end+1} = EEG_incong_correct;
        catch E
            warning("Unable to pop events");
        end

        try
            EEG_incong_incorrect = pop_loadset(append(filename, '_incong_incorrect.set'), savedir);
            epochs_incong_incorrect{end+1} = EEG_incong_incorrect;
        catch E
            warning("Unable to pop events");
        end
    end
end

save(sprintf('%s/data_for_plot_erp.mat', savedir), 'epochs', 'epochs_cong', 'epochs_incong', "epochs_cong_correct", "epochs_cong_incorrect", "epochs_incong_correct", "epochs_incong_incorrect");
%}

load(sprintf('%s/data_for_plot_erp.mat', savedir));

%h = plot_erp({epochs_incong_correct, epochs_incong_incorrect}, 'FCz','avgmode', 'across', 'labels', {'incong-correct', 'incong-incorrect'},  'plotstd', 'fill', 'permute', 1000);
%g = plot_erp({epochs_cong_correct, epochs_cong_incorrect}, 'FCz','avgmode', 'across', 'labels', {'cong-correct', 'cong-incorrect'},  'plotstd', 'fill', 'permute', 1000);
i = plot_erp({epochs_incong_incorrect, epochs_cong_incorrect}, 'FCz','avgmode', 'across', 'labels', {'incong-incorrect', 'cong-incorrect'},  'plotstd', 'fill', 'permute', 1000);
j = plot_erp({epochs_incong_correct, epochs_cong_correct}, 'FCz','avgmode', 'across', 'labels', {'incong-correct', 'cong-correct'},  'plotstd', 'fill', 'permute', 1000);
