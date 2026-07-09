popevent = {'Subject', 'Session', 'Cong_Total', 'Incong_Total', ...
            'Cong_Correct', 'Cong_Incorrect', 'Incong_Correct', 'Incong_Incorrect', ...
            'Grand_Total', 'Low_Trials'};
loaddir = './preprocessed_data/preprocessed_data_new_200to100';
savedir = './preprocessed_data/preprocessed_data_new_200to0';
time_window = [-0.2  0.8];
for subject = 1:29
    for session = 1:3
        filename = 'Flanker.set';
        filename = sprintf('%s_sub-%s_ses-S%d', filename, sprintf('%0*d',(subject<0)+2,subject), session);
        filename_before_epoch = append(filename, '_before_epoch.set');

        % Loading EEG data
        EEG.etc.eeglabvers = '2024.2'; % this tracks which version of EEGLAB is being used, you may ignore it
        EEG = pop_loadset(filename_before_epoch, loaddir);

        % Epoching
        EEG_cong = pop_epoch( EEG, {  '2511'  '2521'  }, time_window, 'cong', 'epochs', 'epochinfo', 'yes');
        EEG_incong = pop_epoch( EEG, {  '2512'  '2522'  }, time_window, 'incong', 'epochs', 'epochinfo', 'yes');
        EEG_all = pop_epoch( EEG, {  '2511'  '2521'  '2512'  '2522'  }, time_window, 'epoched', 'epochs', 'epochinfo', 'yes');
        
        try
            EEG_cong_correct = pop_epoch( EEG, {  '2511'  }, time_window, 'cong', 'epochs', 'epochinfo', 'yes');
        catch
            warning("No epoch was extracted");
        end

        try
            EEG_cong_incorrect = pop_epoch( EEG, {  '2521'  }, time_window, 'cong', 'epochs', 'epochinfo', 'yes');
        catch
            warning("No epoch was extracted");
        end
        
        try
            EEG_incong_correct = pop_epoch( EEG, {  '2512'  }, time_window, 'incong', 'epochs', 'epochinfo', 'yes');
        catch
            warning("No epoch was extracted");
        end
        
        try
            EEG_incong_incorrect = pop_epoch( EEG, {  '2522'  }, time_window, 'incong', 'epochs', 'epochinfo', 'yes');
        catch E
            warning("No epoch was extracted");
        end

        popevent{end+1, 1} = subject;
        popevent{end, 2} = session;
        
        % Total trial counts per main condition
        popevent{end, 3} = EEG_cong.trials;
        popevent{end, 4} = EEG_incong.trials;
        
        % Extract sub-condition counts (use 0 if the variable wasn't created due to error)
        if exist('EEG_cong_correct', 'var') && isstruct(EEG_cong_correct),   popevent{end, 5} = EEG_cong_correct.trials;   else, popevent{end, 5} = 0; end
        if exist('EEG_cong_incorrect', 'var') && isstruct(EEG_cong_incorrect), popevent{end, 6} = EEG_cong_incorrect.trials; else, popevent{end, 6} = 0; end
        if exist('EEG_incong_correct', 'var') && isstruct(EEG_incong_correct), popevent{end, 7} = EEG_incong_correct.trials; else, popevent{end, 7} = 0; end
        if exist('EEG_incong_incorrect', 'var') && isstruct(EEG_incong_incorrect), popevent{end, 8} = EEG_incong_incorrect.trials; else, popevent{end, 8} = 0; end
        
        % Grand Total
        popevent{end, 9} = EEG_cong.trials + EEG_incong.trials;
        
        % Flag low trial sessions
        if popevent{end, 8} < 10
            popevent{end, 10} = '***';
        else
            popevent{end, 10} = '-';
        end
        
        % Clear temporary EEG structures to prevent carry-over to the next iteration
        clear EEG_cong_correct EEG_cong_incorrect EEG_incong_correct EEG_incong_incorrect;
    end
end

% 1. Convert the cell array into a formal MATLAB table
summaryTable = cell2table(popevent(2:end, :), 'VariableNames', popevent(1, :));

% 2. Display individual subject/session logs to the command window
disp('--- SESSION BY SESSION TRIAL BREAKDOWN ---');
disp(summaryTable);

% 3. Calculate and display Group-Level Metrics
disp('--- GROUP LEVEL SUMMARY STATISTICS (Across all Subjects/Sessions) ---');
metrics = {'Cong_Total', 'Incong_Total', 'Cong_Correct', 'Cong_Incorrect', 'Incong_Correct', 'Incong_Incorrect', 'Grand_Total'};

fprintf('%-18s | %-10s | %-10s | %-10s\n', 'Condition', 'Mean Trials', 'Min Trials', 'Max Trials');
fprintf('%s\n', repmat('-', 1, 60));

for m = 1:length(metrics)
    colData = summaryTable.(metrics{m});
    fprintf('%-18s | %-11.1f | %-10d | %-10d\n', ...
            metrics{m}, mean(colData), min(colData), max(colData));
end

% 4. Save summaries to disk
writetable(summaryTable, fullfile(savedir, 'trial_counts_summary.csv'));
