popevent = {'Subject', 'Session', 'Cong', 'Incong', 'Total'};
time_window = [-0.2  0.8];
baseline_correction_interval = [-200, 0];
shift = 0; % in seconds
loaddir = './preprocessed_data/preprocessed_data_new_200to100';
savedir = './preprocessed_data/preprocessed_data_new_200to0';
mkdir(savedir);
mkdir(append(savedir, '/events/'));
mkdir(append(savedir, '/error/'));
error_list = {'Index', 'Error Message', 'Error Identifier'};
for session = 1:3
    for subject = 1:29
        
        
        filename = 'Flanker.set';
        filename = sprintf('%s_sub-%s_ses-S%d', filename, sprintf('%0*d',(subject<0)+2,subject), session);
        filename_before_epoch = append(filename, '_before_epoch.set');

        % Loading EEG data
        EEG.etc.eeglabvers = '2024.2'; % this tracks which version of EEGLAB is being used, you may ignore it
        EEG = pop_loadset(filename_before_epoch, loaddir);

        % Shifting events
        for i = 1:length(EEG.event)
            if ismember(EEG.event(i).type, {'2511'  '2521' '2512'  '2522'})
                EEG.event(i).latency =  EEG.event(i).latency + shift * EEG.srate;
            end
        end
        disp(EEG.event(1).latency)

        % Epoching
        EEG_cong = pop_epoch( EEG, {  '2511'  '2521'  }, time_window, 'cong', 'epochs', 'epochinfo', 'yes');
        EEG_cong = pop_rmbase(EEG_cong, baseline_correction_interval);
        EEG_incong = pop_epoch( EEG, {  '2512'  '2522'  }, time_window, 'incong', 'epochs', 'epochinfo', 'yes');
        EEG_incong = pop_rmbase(EEG_incong, baseline_correction_interval);
        EEG_all = pop_epoch( EEG, {  '2511'  '2521'  '2512'  '2522'  }, time_window, 'epoched', 'epochs', 'epochinfo', 'yes');
        EEG_all = pop_rmbase(EEG_all, baseline_correction_interval);
        EEG_all = pop_saveset( EEG_all, 'filename',sprintf('%s_epoched.set', filename),'filepath',savedir);

        EEG_cong = eeg_checkset( EEG_cong );
        EEG_cong = pop_saveset( EEG_cong, 'filename',sprintf('%s_cong.set', filename),'filepath',savedir);
        pop_expevents(EEG_cong, append(savedir, '/events/', filename, '_event_cong.txt'), 'samples');
        
        EEG_incong = eeg_checkset( EEG_incong );
        EEG_incong = pop_saveset( EEG_incong, 'filename',sprintf('%s_incong.set', filename),'filepath',savedir);
        pop_expevents(EEG_incong, append(savedir, '/events/', filename, '_event_incong.txt'), 'samples');
 
        popevent{end+1, 1} = subject;
        popevent{end, 2} = session;
        popevent{end, 3} = EEG_cong.trials;
        popevent{end, 4} = EEG_incong.trials;
        popevent{end, 5} = EEG_cong.trials + EEG_incong.trials;
        
        if popevent{end, 5} < 120
            popevent{end, 6} = 1;
        else
            popevent{end, 6} = '-';
        end
        
        try
            EEG_cong_correct = pop_epoch( EEG, {  '2511'  }, time_window, 'cong', 'epochs', 'epochinfo', 'yes');
            EEG_cong_correct = pop_rmbase(EEG_cong_correct, baseline_correction_interval);
            EEG_cong_correct = pop_saveset( EEG_cong_correct, 'filename',sprintf('%s_cong_correct.set', filename),'filepath',savedir);
            pop_expevents(EEG_cong_correct, append(savedir, '/events/', filename, '_event_cong_correct.txt'), 'samples');
        catch E
            warning("Unable to pop events");
            error_list{end+1, 1} = sprintf('sub-%d_ses-S%d_cong-correct', subject, session);
            error_list{end, 2} = E.message;
            error_list{end, 3} = E.identifier;
            save(sprintf('%s/error/%s_cong_correct.txt', savedir, filename));
        end

        try
            EEG_cong_incorrect = pop_epoch( EEG, {  '2521'  }, time_window, 'cong', 'epochs', 'epochinfo', 'yes');
            try
                EEG_cong_incorrect = pop_rmbase(EEG_cong_incorrect, baseline_correction_interval);
                EEG_cong_incorrect = pop_saveset( EEG_cong_incorrect, 'filename',sprintf('%s_cong_incorrect.set', filename),'filepath',savedir);
                pop_expevents(EEG_cong_incorrect, append(savedir, '/events/', filename, '_event_cong_incorrect.txt'), 'samples');
            catch E
                warning("Only one epoch was extracted");
                EEG_copy = EEG;
                event_indices = find(strcmp({EEG_copy.event.type}, '2522'));
                next_idx = length(EEG_copy.event) + 1;
                EEG_copy.event(next_idx) = EEG_copy.event(event_indices);
                EEG_cong_incorrect = pop_epoch( EEG_copy, {  '2522'  }, time_window, 'cong', 'epochs', 'epochinfo', 'yes');
                EEG_cong_incorrect = eeg_checkset(EEG_cong_incorrect, 'eventconsistency');
                EEG_cong_incorrect = pop_rmbase(EEG_cong_incorrect, baseline_correction_interval);
                EEG_cong_incorrect = pop_saveset( EEG_cong_incorrect, 'filename',sprintf('%s_cong_incorrect.set', filename),'filepath',savedir);
                pop_expevents(EEG_cong_incorrect, append(savedir, '/events/', filename, '_event_cong_incorrect.txt'), 'samples');

                error_list{end+1,1} = sprintf('sub-%d_ses-S%d_cong-incorrect', subject, session);
                error_list{end, 2} = E.message;
                save(sprintf('%s/error/%s_cong_incorrect.txt', savedir, filename));
            end
        catch E
            warning("No epoch was extracted");
            error_list{end+1,1} = sprintf('sub-%d_ses-S%d_cong-incorrect', subject, session);
            error_list{end, 2} = E.message;
            save(sprintf('%s/error/%s_cong_incorrect.txt', savedir, filename));
        end
        
        try
            EEG_incong_correct = pop_epoch( EEG, {  '2512'  }, time_window, 'incong', 'epochs', 'epochinfo', 'yes');
            EEG_incong_correct = pop_rmbase(EEG_incong_correct, baseline_correction_interval);
            EEG_incong_correct = pop_saveset( EEG_incong_correct, 'filename',sprintf('%s_incong_correct.set', filename),'filepath',savedir);
            pop_expevents(EEG_incong_correct, append(savedir, '/events/', filename, '_event_incong_correct.txt'), 'samples');
        catch E
            warning("Unable to pop events");
            error_list{end+1,1} = sprintf('sub-%d_ses-S%d_incong-correct', subject, session);
            error_list{end, 2} = E.message;
            save(sprintf('%s/error/%s_incong_correct.txt', savedir, filename));
        end
        
        try
            EEG_incong_incorrect = pop_epoch( EEG, {  '2522'  }, time_window, 'incong', 'epochs', 'epochinfo', 'yes');
        catch E
            warning("Unable to pop events");
            error_list{end+1,1} = sprintf('sub-%d_ses-S%d_incong-incorrect', subject, session);
            error_list{end, 2} = E.message;
            error_list{end, 3} = "POP";
            save(sprintf('%s/error/%s_incong_incorrect.txt', savedir, filename));
        end

        try
            EEG_incong_incorrect = pop_rmbase(EEG_incong_incorrect, baseline_correction_interval);
            EEG_incong_incorrect = pop_saveset( EEG_incong_incorrect, 'filename',sprintf('%s_incong_incorrect.set', filename),'filepath',savedir);
            pop_expevents(EEG_incong_incorrect, append(savedir, '/events/', filename, '_event_incong_incorrect.txt'), 'samples');
            
        catch E
            warning("Only one epoch was extracted");
            EEG_copy = EEG;
            event_indices = find(strcmp({EEG_copy.event.type}, '2522'));
            next_idx = length(EEG_copy.event) + 1;
            EEG_copy.event(next_idx) = EEG_copy.event(event_indices);
            EEG_incong_incorrect = pop_epoch( EEG_copy, {  '2522'  }, time_window, 'incong', 'epochs', 'epochinfo', 'yes');
            EEG_incong_incorrect = eeg_checkset(EEG_incong_incorrect, 'eventconsistency');
            EEG_incong_incorrect = pop_rmbase(EEG_incong_incorrect, baseline_correction_interval);
            EEG_incong_incorrect = pop_saveset( EEG_incong_incorrect, 'filename',sprintf('%s_incong_incorrect.set', filename),'filepath',savedir);
            pop_expevents(EEG_incong_incorrect, append(savedir, '/events/', filename, '_event_incong_incorrect.txt'), 'samples');

            error_list{end+1,1} = sprintf('sub-%d_ses-S%d_incong-incorrect', subject, session);
            error_list{end, 2} = E.message;
            error_list{end, 3} = "RMB";
            save(sprintf('%s/error/%s_incong_incorrect.txt', savedir, filename));
        end
    end
end

save(sprintf('%s/error_list', savedir), 'error_list');

