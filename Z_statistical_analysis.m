behavior_summary = [];
behavior_summary_label = {'Subject', 'Reaction time (congruent)', 'Reaction time (incongruent)', 'Accuracy (congruent)', 'Accuracy (incongruent)', 'Error count (congruent)', 'Error count (incongruent)'};

% Reaction time & accuracy
%{
for subject = 1:29
    for session = 1:3
        cong_rts = [];
        incong_rts = [];
        eventcongs = [];
        eventincongs = [];
        error_cong_count = [];
        error_incong_count = [];

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
        cong_avg_rt = mean(cong_rts);
        incong_avg_rt = mean(incong_rts);
    
        eventcong_correct_rate = eventcongs(:, 2) == 2511;
        eventcong_correct_rate = sum(eventcong_correct_rate)/60;
        eventincong_correct_rate = eventincongs(:, 2) == 2512;
        eventincong_correct_rate = sum(eventincong_correct_rate)/60;
        
        error_cong_count = sum(eventcongs(:, 2) == 2521);
        error_incong_count = sum(eventincongs(:, 2) == 2522);

        behavior_summary(end+1, :) = [subject, cong_avg_rt, incong_avg_rt, eventcong_correct_rate, eventincong_correct_rate, error_cong_count, error_incong_count];
    end
end
save('statistics', 'behavior_summary', 'behavior_summary_label');
%}
load('statistics.mat');
behavior_summary(:, 2) = behavior_summary(:, 2) * 1000; 
behavior_summary(:, 3) = behavior_summary(:, 3) * 1000; 
behavior_summary(:, 4) = behavior_summary(:, 4) * 100; 
behavior_summary(:, 5) = behavior_summary(:, 5) * 100; 

alpha = 0.05;

rt_cong = behavior_summary(:,2);
rt_incong = behavior_summary(:,3);
rt_diff = rt_cong - rt_incong;
behavior_summary(:, end+1) = rt_diff;

acc_cong = behavior_summary(:,4);
acc_incong = behavior_summary(:,5);
acc_diff = acc_cong - acc_incong;
behavior_summary(:, end+1) = acc_diff;

error_cong_count = behavior_summary(:,6);
error_incong_count = behavior_summary(:,7);
error_diff = error_cong_count - error_incong_count;
behavior_summary(:, end+1) = error_diff;

colMeans = mean(behavior_summary, 1); 
colSTDs = std(behavior_summary); 

[h_rt,p_rt] = ttest(rt_cong,  rt_incong,'Alpha',alpha);
effect_rt = meanEffectSize(rt_cong,rt_incong,Paired=true,Effect="robustcohen",Alpha=alpha);

[h_acc,p_acc] = ttest(acc_cong,  acc_incong,'Alpha',alpha);
effect_acc = meanEffectSize(acc_cong,acc_incong,Paired=true,Effect="robustcohen",Alpha=alpha);

[h_error,p_error] = ttest(error_cong_count,  error_incong_count,'Alpha',alpha);
% Change "robustcohen" to "cohen" or "hedges"
effect_error = meanEffectSize(error_cong_count, error_incong_count, Paired=true, Effect="robustcohen", Alpha=alpha);
