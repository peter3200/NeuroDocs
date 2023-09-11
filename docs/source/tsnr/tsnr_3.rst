tSNR Step 3: Within-Network Averaging
=====================================

Overview
********

After generating tSNR maps for each session and projecting them to the fsaverage6 surface, we can go ahead and average tSNR across sessions within each subject and even average within network boundaries using individual parcellations. The following script takes as input Kong2019 Hungarian-matched individual parcellations and fsaverage6-projected tSNR maps. The script can be easily altered to accommodate different resolutions of tSNR maps or parcellations. Note, however, that the resolution of the parcellation and the tSNR maps should match. 

Step 3 Script
*************

To perform this step, we will use a MATLAB script. 

.. code-block:: matlab 

    % Purpose: Convert fsaverage6 SNR maps to .mat matrices, avg over sessions
    % and within networks
    % Inputs: LH and RH step2 .shape.gii output, individual parc output
    % (matched)
    % Outputs: subject-avg SNR .mat, .csv file containing network-avg SNR for each subject
    %
    % Note: This requires the use of the gifti package (part of CBIG repo)
    %
    % Written by M. Peterson, Nielsen Brain and Behavior Lab, under MIT License 2023

    % To run: 
    %	 1. Claim computing resources using salloc (ex: `salloc --mem-per-cpu 100G --time 48:00:00 --x11`)
    %	 2. Load matlab module: `ml matlab/r2018b`
    %	 3. Source your CBIG config script
    %	 4. Enter the command `LD_PRELOAD= matlab`

    % Set paths and variables
    snr_dir = '/fslgroup/grp_hcp/compute/HCP_analysis/parc_output_fs6_HCP_ALL/quant_metrics/tSNR';
    parc_dir = '/fslgroup/grp_hcp/compute/HCP_analysis/parc_output_fs6_HCP_ALL/generate_individual_parcellations/ind_parcellation/test_set';
    out_dir= '/fslgroup/fslg_spec_networks/compute/code/HCP_analysis/tSNR/ALL';

    %Load text file
        filename = '/nobackup/scratch/grp/fslg_spec_networks/code/HCP_analysis/tSNR/ALL/ids.txt';
        delimiter = {''};
        % Format for each line of text:
        %   column1: text (%s)
        % For more information, see the TEXTSCAN documentation.
        formatSpec = '%s%[^\n\r]';
        % Open the text file.
        fileID = fopen(filename,'r');
        % Read columns of data according to the format.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
        % Close the text file.
        fclose(fileID);
        sublist = [dataArray{1:end-1}];
        clearvars filename delimiter formatSpec fileID dataArray ans;

    seslist=["1" "2" "3" "4" ];
    count=0;
    %Loop through each subject
    for subid = 1:length(sublist)
        sub=sublist(subid);
            %Load subject's individual parcellation
            count=count+1;
            parc_file = strcat('Ind_parcellation_MSHBM_sub', num2str(count), '_w200_MRF30_matched.mat');
            parc_full = load(fullfile(parc_dir, parc_file));
            
            ses_count=0;
        for ses = seslist
            %file names for tSNR maps in fs6
            lh_file = strcat('sub-', sub, '_sess-', ses, '_lh.shape.gii');     
            rh_file = strcat('sub-', sub, '_sess-', ses, '_rh.shape.gii');
            lh_inputfull = fullfile(snr_dir, lh_file);
            rh_inputfull = fullfile(snr_dir, rh_file);

            %check if file exists before proceeding to load and avg
            if isfile(lh_inputfull)
                ses_count=ses_count+1;
                %load gifti files
                lh_gifti = gifti(char(lh_inputfull));
                rh_gifti = gifti(char(rh_inputfull));
        
                %save activation data in matrix format
                lh_labels = lh_gifti.cdata
                rh_labels = rh_gifti.cdata

            else
            end
            
            if ses_count==1
                comb_left = lh_labels;
                comb_right = rh_labels;
                
            elseif ses_count>1
                comb_left = cat(3, comb_left, lh_labels);
                comb_right= cat(3, comb_right, rh_labels);
            else
            end
        end
        
        %Avg within subject
        avg_left = mean(comb_left,3);
        avg_right = mean(comb_right,3);
            
        %save ind avg output
        if(~exist(out_dir))
            mkdir(out_dir);
        end
        save(fullfile(snr_dir, strcat('sub-', sub, '_AVG_SNR_FS6.mat')), 'avg_left','avg_right');

        
        %Avg. within-network SNR for each subject
        for network = 1:17
                
            %Find indices for parc where Network = $network and take average in SNR (LH and RH
            %separately)
            lh_SNR_avg = mean(avg_left(parc_full.lh_labels == network)); 
            rh_SNR_avg = mean(avg_right(parc_full.rh_labels == network)); 
            
            %Append subject and network avg SNR to array (LH and RH separately)
            if network == 1
                subject_array = {sub, network, lh_SNR_avg, rh_SNR_avg};
            else
                added_array = {sub, network, lh_SNR_avg, rh_SNR_avg};
                subject_array = vertcat(subject_array, added_array);
            end
        end    
        
        %Append subject array of network-avg SNR to group array
        if count ==1
            group_array = subject_array;
        else
            group_array = vertcat(group_array, subject_array);
        end
        
    end

    %Save out group array of network avg SNR to .csv
    % Create a table from the array
    table_data = array2table(group_array, 'VariableNames', {'SUBJID', 'Network', 'LH_AVG_SNR', 'RH_AVG_SNR'});

    % Define the filename for the .csv file
    filename = fullfile(out_dir, 'HCP_Network_AVG_SNR_230614.csv');

    % Write the table to a .csv file
    writetable(table_data, filename);

Expected Output
***************

* A .csv file containing network-averaged tSNR values for each subject for 17 networks 
* A .mat file for each subject with the averaged tSNR values (averaged across sessions)