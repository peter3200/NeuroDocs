Split A BOLD Run
================

How?
****

Using Matlab! The CBIG group has written a very useful function-- CBIG_GrabFrames. This function requires the full path and file name to the BOLD image being split, the full path and file name to the output, and the desired frames.

Example Matlab Code
*******************

This example script takes a Midnight Scan Club BOLD run and splits it into 5 equal parts. Each fifth of the run is written out as its own file. 

.. code-block:: matlab

    % Purpose: Split MSC timeseries into 5 pieces and create FC matrices for
    % each fifth in order to aid in Stable Estimate of AI calculation.
    % Inputs: A single run (CBIG2016 preprocessed) of MSC data.
    % Outputs: 5 FC matrices per individual run. 
    %
    % Written by M. Peterson, Nielsen Brain and Behavior Lab, under MIT License 2022

    % To run: 
    %	 1. Claim computing resources using salloc (ex: `salloc --mem-per-cpu 300G --time 48:00:00 --x11`)
    %	 2. Load matlab module: `ml matlab/r2018b`
    %	 3. Enter the command `LD_PRELOAD= matlab`


    % Set paths
    preproc_dir = '/fslgroup/fslg_spec_networks/compute/data/MSC';
    project_dir = '/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/STABLE_EST/split5_BOLD';
    out_dir = strcat(project_dir, '/t_series');
    sublist = ["MSC02" "MSC04" "MSC05" "MSC06" "MSC07"];


    %make out_dir
    if(~exist(out_dir))
        mkdir(out_dir);
    end
    
    
    for i = sublist
        for ses = 1:4
        %input filenames
        both_filename=strcat('sub-', i, '_ses-func0', num2str(ses), '_task-rest_bold.nii.gz');
        str = fullfile(preproc_dir, strcat('sub-',i), strcat('ses-func0', num2str(ses)),'func', both_filename);
        both = MRIread(char(str));
        
            for pieces = 1:5 
            
            %subsample: range_start:range_end
        if pieces==1
                range_start = 1;
            else
                range_start = floor(size(both.vol,4)*((pieces - 1) *.2));
        end
            range_end = floor(size(both.vol, 4)*(pieces * .2));
        
            %output name
            both_file_out = strcat('sub-', i, '_ses-', num2str(ses), '_', 'pieces-', num2str(pieces), '.nii.gz');
            both_file_full = fullfile(out_dir,both_file_out);
        
            %call CBIG function to write output (input, output, subsample)
            %lh
            CBIG_GrabFrames(str, both_file_full, [range_start:range_end]);
            
        end
        end
    end
