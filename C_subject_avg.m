fidpnt = [1 85 -41 ; -83 -20 -65 ; 83 -20 -65];

for subject = 1:29
    EEG_data = {[], [], [], []};
    EEG_avg_data = {};

    for session = 1:3
     
        dir = './preprocessed_data/preprocessed_data_new_200to0';
        save_dir = './spm_compatible_data/subject_avg_200to0';
        mkdir(save_dir)
        filename = sprintf('%s_sub-%s_ses-S%d', 'Flanker.set', sprintf('%0*d',(subject<0)+2,subject), session);
        filedir = append(dir, '/', filename);
        % -----------------------------------------------------------------
        % Cong | Correct
        
        label = 'cong_correct';
        
        subdir = sprintf('%s_%s.set', filedir, label);
        
        if ~exist(subdir, 'file')
            fprintf('%s: NOT FOUND!!\n', subdir);
        else
            EEG = pop_loadset(subdir);
            EEG_temp = EEG;
    
            if session == 1
                EEG_data{1} = EEG.data;
            else
                EEG_data{1} = cat(3, EEG_data{1}, EEG.data); 
            end
        end
        
        % -----------------------------------------------------------------
        % Cong | Incorrect
        
        label = 'cong_incorrect';
        
        subdir = sprintf('%s_%s.set', filedir, label);
        
        if ~exist(subdir, 'file')
            fprintf('%s: NOT FOUND!!\n', subdir);
        else
            EEG = pop_loadset(subdir);
            if session == 1
                EEG_data{2} = EEG.data;
            else
                EEG_data{2} = cat(3, EEG_data{2}, EEG.data); 
            end
        end

        % -----------------------------------------------------------------
        % Incong | Correct
        
        label = 'incong_correct';
        
        subdir = sprintf('%s_%s.set', filedir, label);
        
        if ~exist(subdir, 'file')
            fprintf('%s: NOT FOUND!!\n', subdir);
        else
            EEG = pop_loadset(subdir);
            if session == 1
                EEG_data{3} = EEG.data;
            else
                EEG_data{3} = cat(3, EEG_data{3}, EEG.data); 
            end
        end
        
        % -----------------------------------------------------------------
        % Incong | Incorrect
        
        label = 'incong_incorrect';
        
        subdir = sprintf('%s_%s.set', filedir, label);
        
        if ~exist(subdir, 'file')
            fprintf('%s: NOT FOUND!!\n', subdir);
        else
            EEG = pop_loadset(subdir);
            if session == 1
                EEG_data{4} = EEG.data;
            else
                EEG_data{4} = cat(3, EEG_data{4}, EEG.data); 
            end
        end

    end

    for i = 1:length(EEG_data)
        disp(size(EEG_data{i}, 3));
        avg = sum(EEG_data{i}, 3) / size(EEG_data{i}, 3); % Same as mean
        EEG_avg_data{i} = avg;
    end
    % -----------------------------------------------------------------
    % Congruent average
    
    label = 'cong';
    
    dir = save_dir;
    subdir = sprintf('%s/%s_%s_avg.set', dir, filename, label);
    savedir = sprintf('%s/Flanker-sub%s_%s_avg.set', dir, sprintf('%0*d',(subject<0)+2,subject), label);
    
    EEG = EEG_temp;
    EEG.data = cat(3, EEG_avg_data{1}, EEG_avg_data{2});
    
    EEG.trials = size(EEG.data, 3);

    % Convert to SPM compatible files
    
    EEG.event = struct('type', {2511, 2512}, 'latency', {51, 301}, 'duration', 0.5, 'epoch', {1, 2});
    
    ft_data = eeglab2fieldtrip(EEG, 'raw');
    
    % Add channel locations
    elec = ft_data.elec;
    
    elecposX = elec.elecpos(:,2);
    elecposX(:,1) = elecposX(:,1) * -1;
    elecposY = elec.elecpos(:,1);
    elec.elecpos(:,2) = elecposY;
    elec.elecpos(:,1) = elecposX;
    elec.pnt(:,2) = elecposY;
    elec.pnt(:,1) = elecposX;
    
    cfg = [];
    cfg.elec = elec;
    cfg.feedback = 'yes';
    layout = ft_prepare_layout(cfg);
    % save('./spm_compatible/channel_locations.mat', 'layout');
    
    
    % Now use SPM to convert this FieldTrip structure into an SPM-compatible EEG structure
    S = [];
    S.outfile = sprintf('%s.mat', savedir);  % The output SPM MEEG file name
    S.mode = 'continuous';  % Since it's continuous EEG data
    D = spm_eeg_ft2spm(ft_data, S.outfile);  % Convert the data
    
    % Check if the EEG data has been properly converted to the SPM format
    disp(D);
    
    
    % Configure sensor locations etc...
    data = load(S.outfile);  % Adjust to your actual data file
    
    data.D.sensors = struct('eeg', '');
    
    data.D.sensors.eeg.chanpos = elec.elecpos;
    data.D.sensors.eeg.chantype = layout.cfg.elec.chantype;
    data.D.sensors.eeg.elecpos = elec.elecpos;
    data.D.sensors.eeg.label = transpose(elec.label);
    data.D.sensors.eeg.type = layout.cfg.elec.type;
    data.D.sensors.eeg.unit = layout.cfg.elec.unit;
    
    data.D.condlist = {'cong_correct', 'cong_incorrect', 'incong_correct', 'incong_incorrect'};
    
    data.D.trials(1).label = sprintf('%s_correct', label);
    data.D.trials(1).bad = 0;
    data.D.trials(1).tag = [];
    data.D.trials(1).events = [];
    data.D.trials(1).onset = 0;
    data.D.trials(1).repl = 1;
    
    data.D.trials(2).label = sprintf('%s_incorrect', label);
    data.D.trials(2).bad = 0;
    data.D.trials(2).tag = [];
    data.D.trials(2).events = [];
    data.D.trials(2).onset = 0;
    data.D.trials(2).repl = 1;
    
    data.D.fiducials = struct('fid', '');
    data.D.fiducials.fid.label = {'nas' ; 'lpa' ; 'rpa'};
    data.D.fiducials.fid.pnt = fidpnt;
    
    D = data.D;
    
    save(S.outfile, 'D');  % Save the file
    
    
    % -----------------------------------------------------------------
    % Incongruent average
    
    label = 'incong';
    
    subdir = sprintf('%s/%s_%s_avg.set', dir, filename, label);
    savedir = sprintf('%s/Flanker-sub%s_%s_avg.set', dir, sprintf('%0*d',(subject<0)+2,subject), label);
    
    EEG.data = cat(3, EEG_avg_data{3}, EEG_avg_data{4});
    EEG.trials = size(EEG.data, 3);

    
    % Convert to SPM compatible files
    
    ft_data = eeglab2fieldtrip(EEG, 'raw');
    
    % Add channel locations
    elec = ft_data.elec;
    
    elecposX = elec.elecpos(:,2);
    elecposX(:,1) = elecposX(:,1) * -1;
    elecposY = elec.elecpos(:,1);
    elec.elecpos(:,2) = elecposY;
    elec.elecpos(:,1) = elecposX;
    elec.pnt(:,2) = elecposY;
    elec.pnt(:,1) = elecposX;
    
    cfg = [];
    cfg.elec = elec;
    cfg.feedback = 'yes';
    layout = ft_prepare_layout(cfg);
    % save('./spm_compatible/channel_locations.mat', 'layout');
    
    
    % Now use SPM to convert this FieldTrip structure into an SPM-compatible EEG structure
    S = [];
    S.outfile = sprintf('%s.mat', savedir);  % The output SPM MEEG file name
    S.mode = 'continuous';  % Since it's continuous EEG data
    D = spm_eeg_ft2spm(ft_data, S.outfile);  % Convert the data
    
    % Check if the EEG data has been properly converted to the SPM format
    disp(D);
    
    
    % Configure sensor locations etc...
    data = load(S.outfile);  % Adjust to your actual data file
    
    data.D.sensors = struct('eeg', '');
    
    data.D.sensors.eeg.chanpos = elec.elecpos;
    data.D.sensors.eeg.chantype = layout.cfg.elec.chantype;
    data.D.sensors.eeg.elecpos = elec.elecpos;
    data.D.sensors.eeg.label = transpose(elec.label);
    data.D.sensors.eeg.type = layout.cfg.elec.type;
    data.D.sensors.eeg.unit = layout.cfg.elec.unit;
    
    data.D.condlist = {'cong_correct', 'cong_incorrect', 'incong_correct', 'incong_incorrect'};
    
    data.D.trials(1).label = sprintf('%s_correct', label);
    data.D.trials(1).bad = 0;
    data.D.trials(1).tag = [];
    data.D.trials(1).events = [];
    data.D.trials(1).onset = 0;
    data.D.trials(1).repl = 1;
    
    data.D.trials(2).label = sprintf('%s_incorrect', label);
    data.D.trials(2).bad = 0;
    data.D.trials(2).tag = [];
    data.D.trials(2).events = [];
    data.D.trials(2).onset = 0;
    data.D.trials(2).repl = 1;
    
    data.D.fiducials = struct('fid', '');
    data.D.fiducials.fid.label = {'nas' ; 'lpa' ; 'rpa'};
    data.D.fiducials.fid.pnt = fidpnt;
    
    D = data.D;
    
    save(S.outfile, 'D');  % Save the file
    
    % -----------------------------------------------------------------
    % Correct average
    
    label = 'correct';
    
    subdir = sprintf('%s/%s_%s_avg.set', dir, filename, label);
    savedir = sprintf('%s/Flanker-sub%s_%s_avg.set', dir, sprintf('%0*d',(subject<0)+2,subject), label);

    EEG.data = cat(3, EEG_avg_data{1}, EEG_avg_data{3});
    EEG.trials = size(EEG.data, 3);
    % Convert to SPM compatible files
    
    ft_data = eeglab2fieldtrip(EEG, 'raw');
    
    % Add channel locations
    elec = ft_data.elec;
    
    elecposX = elec.elecpos(:,2);
    elecposX(:,1) = elecposX(:,1) * -1;
    elecposY = elec.elecpos(:,1);
    elec.elecpos(:,2) = elecposY;
    elec.elecpos(:,1) = elecposX;
    elec.pnt(:,2) = elecposY;
    elec.pnt(:,1) = elecposX;
    
    cfg = [];
    cfg.elec = elec;
    cfg.feedback = 'yes';
    layout = ft_prepare_layout(cfg);
    % save('./spm_compatible/channel_locations.mat', 'layout');
    
    
    % Now use SPM to convert this FieldTrip structure into an SPM-compatible EEG structure
    S = [];
    S.outfile = sprintf('%s.mat', savedir);  % The output SPM MEEG file name
    S.mode = 'continuous';  % Since it's continuous EEG data
    D = spm_eeg_ft2spm(ft_data, S.outfile);  % Convert the data
    
    % Check if the EEG data has been properly converted to the SPM format
    disp(D);
    
    
    % Configure sensor locations etc...
    data = load(S.outfile);  % Adjust to your actual data file
    
    data.D.sensors = struct('eeg', '');
    
    data.D.sensors.eeg.chanpos = elec.elecpos;
    data.D.sensors.eeg.chantype = layout.cfg.elec.chantype;
    data.D.sensors.eeg.elecpos = elec.elecpos;
    data.D.sensors.eeg.label = transpose(elec.label);
    data.D.sensors.eeg.type = layout.cfg.elec.type;
    data.D.sensors.eeg.unit = layout.cfg.elec.unit;
    
    data.D.condlist = {'cong_correct', 'cong_incorrect', 'incong_correct', 'incong_incorrect'};
    
    data.D.trials(1).label = sprintf('cong_%s', label);
    data.D.trials(1).bad = 0;
    data.D.trials(1).tag = [];
    data.D.trials(1).events = [];
    data.D.trials(1).onset = 0;
    data.D.trials(1).repl = 1;
    
    data.D.trials(2).label = sprintf('incong_%s', label);
    data.D.trials(2).bad = 0;
    data.D.trials(2).tag = [];
    data.D.trials(2).events = [];
    data.D.trials(2).onset = 0;
    data.D.trials(2).repl = 1;
    
    data.D.fiducials = struct('fid', '');
    data.D.fiducials.fid.label = {'nas' ; 'lpa' ; 'rpa'};
    data.D.fiducials.fid.pnt = fidpnt;
    
    D = data.D;
    
    save(S.outfile, 'D');  % Save the file
    
    % -----------------------------------------------------------------
    % Incorrect average
    
    label = 'incorrect';
    
    subdir = sprintf('%s/%s_%s_avg.set', dir, filename, label);
    savedir = sprintf('%s/Flanker-sub%s_%s_avg.set', dir, sprintf('%0*d',(subject<0)+2,subject), label);

    EEG.data = cat(3, EEG_avg_data{2}, EEG_avg_data{4});
    EEG.trials = size(EEG.data, 3);
    % Convert to SPM compatible files
    
    ft_data = eeglab2fieldtrip(EEG, 'raw');
    
    % Add channel locations
    elec = ft_data.elec;
    
    elecposX = elec.elecpos(:,2);
    elecposX(:,1) = elecposX(:,1) * -1;
    elecposY = elec.elecpos(:,1);
    elec.elecpos(:,2) = elecposY;
    elec.elecpos(:,1) = elecposX;
    elec.pnt(:,2) = elecposY;
    elec.pnt(:,1) = elecposX;
    
    cfg = [];
    cfg.elec = elec;
    cfg.feedback = 'yes';
    layout = ft_prepare_layout(cfg);
    
    
    % Now use SPM to convert this FieldTrip structure into an SPM-compatible EEG structure
    S = [];
    S.outfile = sprintf('%s.mat', savedir);  % The output SPM MEEG file name
    S.mode = 'continuous';  % Since it's continuous EEG data
    D = spm_eeg_ft2spm(ft_data, S.outfile);  % Convert the data
    
    % Check if the EEG data has been properly converted to the SPM format
    disp(D);
    
    
    % Configure sensor locations etc...
    data = load(S.outfile);  % Adjust to your actual data file
    
    data.D.sensors = struct('eeg', '');
    
    data.D.sensors.eeg.chanpos = elec.elecpos;
    data.D.sensors.eeg.chantype = layout.cfg.elec.chantype;
    data.D.sensors.eeg.elecpos = elec.elecpos;
    data.D.sensors.eeg.label = transpose(elec.label);
    data.D.sensors.eeg.type = layout.cfg.elec.type;
    data.D.sensors.eeg.unit = layout.cfg.elec.unit;
    
    data.D.condlist = {'cong_correct', 'cong_incorrect', 'incong_correct', 'incong_incorrect'};
    
    data.D.trials(1).label = sprintf('cong_%s', label);
    data.D.trials(1).bad = 0;
    data.D.trials(1).tag = [];
    data.D.trials(1).events = [];
    data.D.trials(1).onset = 0;
    data.D.trials(1).repl = 1;
    
    data.D.trials(2).label = sprintf('incong_%s', label);
    data.D.trials(2).bad = 0;
    data.D.trials(2).tag = [];
    data.D.trials(2).events = [];
    data.D.trials(2).onset = 0;
    data.D.trials(2).repl = 1;
    
    data.D.fiducials = struct('fid', '');
    data.D.fiducials.fid.label = {'nas' ; 'lpa' ; 'rpa'};
    data.D.fiducials.fid.pnt = fidpnt;
    
    D = data.D;
    
    save(S.outfile, 'D');  % Save the file

end