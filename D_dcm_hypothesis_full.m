% PS. I edited the spm_eeg_inv_mesh_ui.m , spm_eeg_inv_datareg_ui.m ,
% spm_eeg_inv_forward_ui.m
rootdata = '.\spm_compatible_data\subject_avg_200to0';
savedcmdir = '.\dcm_full';
DCM_template_list = getAllFiles('./dcm_template');
excluded_subjects = [8, 18];

for subject = 1:29
    if ismember(subject, excluded_subjects)
        continue;
    end
    for i = 1:size(DCM_template_list, 1)
        [filepath,name,ext] = fileparts(DCM_template_list{i});
    
        DCM_template = load(DCM_template_list{i});
        DCM_template = DCM_template.DCM;
            
        DCM = DCM_template;
        
        spm('defaults','EEG');
        
        % Data and analysis directories
        
        Pbase     = '.';        % directory with your data, 
        
        Pdata     = fullfile(Pbase, rootdata); % data directory in Pbase
        Panalysis = fullfile(Pbase, savedcmdir); % analysis directory in Pbase
        
        % Data filename
        filename = sprintf('Flanker-sub%s_incorrect_avg', sprintf('%0*d',(subject<0)+2,subject));
        dirdata = sprintf('%s.set.mat', filename);
        dirdata = append(rootdata, '\',dirdata );
        
        disp(dirdata)
        if ~exist(dirdata, 'file')
            str = "Data not exist!: " + dirdata;
            warning(str)
            continue
        end

        DCM.name = sprintf('DCM_%s-%s', name, filename);
        disp(DCM.name)
    
        if exist(sprintf('%s.mat',DCM.name), 'file')
            str = "File already exist!: "+ sprintf('%s.mat',DCM.name);
            disp(str)
            continue
        end
        
        DCM.xY.Dfile = dirdata;
        
        
        % Invert
        try
            DCM      = spm_dcm_erp(DCM);
        catch
            continue;
        end
    
    end
end

beep();
pause(1);
beep();
pause(1);
beep();

function fileList = getAllFiles(dirName)

  dirData = dir(dirName);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
  end

end

