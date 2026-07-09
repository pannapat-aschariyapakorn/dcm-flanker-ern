% 1: dACC, 2: L_IFG, 3: L_SMA, 4: L_dlPFC, 5: R_IFG, 6: R_SMA, 7: R_dlPFC
vertices = {'dACC', 'L_IFG', 'L_SMA', 'L_dlPFC', 'R_IFG', 'R_SMA', 'R_dlPFC'};

groups = struct();
groups(1).name = 'dACC';          groups(1).L = 1; groups(1).R = 1; 
groups(2).name = 'IFG';           groups(2).L = 2; groups(2).R = 5; 
groups(3).name = 'SMA';           groups(3).L = 3; groups(3).R = 6; 
groups(4).name = 'dlPFC';         groups(4).L = 4; groups(4).R = 7; 

group_indices = 1:4;
all_orders = perms(group_indices);
all_orders = flip(all_orders, 1);
num_permutations = size(all_orders, 1);

fprintf('Total number of hierarchical permutations: %d\n\n', num_permutations);

adjacency_matrices = cell(num_permutations, 1);

for k = 1:num_permutations
    current_order = all_orders(k, :);
    
    adj_matrix = zeros(7, 7);
    
    for i = 1:length(current_order)
        for j = (i + 1):length(current_order)
            src_tier = current_order(i);
            tgt_tier = current_order(j);
            
            adj_matrix(groups(src_tier).L, groups(tgt_tier).L) = 1;
            adj_matrix(groups(src_tier).R, groups(tgt_tier).R) = 1;
        end
    end
    
    adj_matrix(1, 1) = 0;
    
    adjacency_matrices{k} = adj_matrix;
end

% Create DCM Templates
template_root = './dcm_template/';
DCM_template = load('template_for_dcm.mat');
DCM = DCM_template.DCM;
filenames = {};
for i = 1:length(all_orders)
    DCM.A{1,2} = adjacency_matrices{i,1};
    DCM.A{1,1} = adjacency_matrices{i,1}';
    DCM.B{1,1} = eye(7) | DCM.A{1,1} | DCM.A{1,2} | DCM.A{1,3};
    
    order = all_orders(i,:);
    if order(1) == 1
        DCM.C = [1;0;0;0;0;0;0];
    else
        C = [0,0,0,0,0,0,0];
        C(order(1)) = 1;
        C(order(1)+3) = 1;
        DCM.C = C';
    end
    order = strjoin(strsplit(num2str(order)), '-');
    filename = sprintf('M_%s', order);
    filenames{end+1} = filename;
    save(sprintf('%s%s.mat',template_root,filename), 'DCM');
end
filenames = filenames';
save("model_names", "filenames")