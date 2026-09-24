folder = './peb_analysis/individual_model/';
excluded_subjects = [8, 18]; % 8, 18
behavior_summary = [];
behavior_summary_label = {'Subject', 'Reaction time (congruent)', 'Reaction time (incongruent)', 'Accuracy (congruent)', 'Accuracy (incongruent)'};

% Reaction time & accuracy
for subject = 1:29
    if ismember(subject, excluded_subjects)
        continue;
    end
    cong_rts = [];
    incong_rts = [];
    eventcongs = [];
    eventincongs = [];
    for session = 1:3
        datadir = sprintf('./raw_data/sub-%s/ses-S%d/behavioral/Flanker.mat', sprintf('%0*d',(subject<0)+2,subject), session);
        flanker = load(datadir);
        flanker = flanker.flanker;
        flanker = table2array(flanker);
        
        cong_check = (flanker(:, 2) == 1) & (flanker(:, 1) > 0);
        cong_rt = flanker(cong_check, 1);
        cong_rts = [cong_rts; cong_rt];
        
        incong_check = flanker(:, 2) == 0 & flanker(:, 1) > 0;
        incong_rt = flanker(incong_check, 1);
        incong_rts = [incong_rts;incong_rt];

        eventcongdir = sprintf('./preprocessed_data/preprocessed_data_new_200to0/events/Flanker.set_sub-%s_ses-S%d_event_cong.txt', sprintf('%0*d',(subject<0)+2,subject), session);
        eventcong = readtable(eventcongdir, 'Delimiter', '\t');
        eventcong = table2array(eventcong);
        eventcongs = [eventcongs;eventcong];
        
        eventincongdir = sprintf('./preprocessed_data/preprocessed_data_new_200to0/events/Flanker.set_sub-%s_ses-S%d_event_incong.txt', sprintf('%0*d',(subject<0)+2,subject), session);
        eventincong = readtable(eventincongdir, 'Delimiter', '\t');
        eventincong = table2array(eventincong);
        eventincongs = [eventincongs;eventincong];
    end

    cong_avg_rt = mean(cong_rts);
    incong_avg_rt = mean(incong_rts);

    eventcong_correct_rate = eventcongs(:, 2) == 2511;
    eventcong_correct_rate = sum(eventcong_correct_rate)/180;
    eventincong_correct_rate = eventincongs(:, 2) == 2512;
    eventincong_correct_rate = sum(eventincong_correct_rate)/180;

    behavior_summary(end+1, :) = [subject, cong_avg_rt, incong_avg_rt, eventcong_correct_rate, eventincong_correct_rate];
end

% behavior_summary(:, end+1) = RSME(:, 3);

design_matrix = [ones(27,1), behavior_summary(:, :)];

save(append(folder, 'design_matrix.mat'), 'behavior_summary', 'behavior_summary_label', 'design_matrix');
