K-means Parc Step 1: Concatenate Timeseries
===========================================

Step 1 Overview 
***************

In the case where participants have multiple runs of rs-fMRI data, we are going to concatenate those runs so that each participant has one file. The concatenated run will then be fed into the kmeans algorithm in Step 2. 

Step 1 Script
*************

This script assumes that preprocessing and surface projection of the data has already taken place. 

.. note:: The more runs a participant has, the more memory and time this script will require. 

This script is implemented in MATLAB/r2018b. Also, this script was written for MSC dataset, which only has 10 participants. It could easily be adapted for parallel processing. 

.. code-block:: matlab 

    % Purpose: Concatenate timeseries within individuals
    % Input: CBIG2016 preproc.
    % Output: Concatenated timeseries for each participant
    % 
    % Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License 2022.

    %To run: 
    %	 1. Claim computing resources using salloc (ex: `salloc --mem-per-cpu 300G --time 48:00:00 --x11`)
    %	 2. Load matlab module: `ml matlab/r2018b`
    %	 3. Enter the command `LD_PRELOAD= matlab`


    % Step  1: Concatenate runs within an individual to create a single timeseries
    project_dir = '/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_EVEN_GROUP/quant_metrics/kmeans';
    prep_dir = '/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/CBIG2016_preproc_FS6';
    sublist = ["MSC01" "MSC02" "MSC03" "MSC04" "MSC05" "MSC06" "MSC07" "MSC08" "MSC09" "MSC10"];
    seslist = ["2" "4" "6" "8" "10"];

    % Create output directory
    if(~exist(project_dir))
            mkdir(project_dir);
    end


    % Loop through each subj and each session (run) -- concatenate each surface-projected run over time
    for sub = sublist
        count=0;
        for ses = seslist
            %vars for file names num2str(num,'%03.f')
            %lh
            lh_filename = strcat('lh.sub-',sub,'_bld', num2str(str2num(ses), '%03.f'), '_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz');
            lh_fullfile = fullfile(prep_dir,strcat('sub-',sub),strcat('sub-',sub),'surf',lh_filename); 		
            %rh
            rh_filename = strcat('rh.sub-',sub,'_bld', num2str(str2num(ses), '%03.f'), '_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz');
            rh_fullfile = fullfile(prep_dir,strcat('sub-',sub), strcat('sub-',sub),'surf',rh_filename);

            %if file exists
            if isfile(lh_fullfile)
                    count=(count+1);
                    
                    %read in files (RH and LH)
                    input_series = MRIread(char(rh_fullfile));
                    t_series1 = single(transpose(reshape(input_series.vol, size(input_series.vol, 1) * size(input_series.vol, 2) * size(input_series.vol, 3), size(input_series.vol, 4))));

                    input_series = MRIread(char(lh_fullfile));
                    t_series2 = single(transpose(reshape(input_series.vol, size(input_series.vol, 1) * size(input_series.vol, 2) * size(input_series.vol, 3), size(input_series.vol, 4))));
            
                    %concatenate RH and LH into one timeseries
                    t_series = [t_series1 t_series2];       
            
            %concatenate runs within individual
                    if count==1
                        sub_series = t_series;
                    else
                        %sub_series = append(sub_series,t_series);
                        sub_series = [sub_series; t_series];
                    end
            
            else
            end    
        end
        
        %transpose matrix for kmeans input
        sub_series2 = transpose(sub_series);
        
        %write out sub_series
        out_name = strcat('sub-',sub,'_concat_tseries.mat');  
        output_file = fullfile(project_dir,out_name);
        save(output_file, 'sub_series2', '-v7.3');
    
    end

Expected Output
***************

You should expect the output of one concatenated timeseries per participant in the format of "sub-$SUB_concat_tseries.mat".