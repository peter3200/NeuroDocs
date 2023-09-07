K-means Parc Step 2: K-means Algorithm
======================================

Step 2 Overview 
***************

Now that we have concatenated each participant's timeseries, we can go ahead and generate the k-means parcellations. There are several parameters which one can alter, including the k (number of networks), the distance metric, maximum number of iterations, and number of replications. The following script has used the default parameters (following Braga et al., 2020), with the exception of the k, which was set at 17 for comparison against the Kong2019 17-network parcellations. 

Step 2 Script 
*************

Once again, we will be using MATLAB to implement the kmeans algorithm. As before, the script was written with the MSC dataset in mind, but it could easily be adapted for parallel processing. 

.. code-block:: matlab 

    % Purpose: K-means parcellations for rs-fMRI data for each subject
    % Input: Single concatenated timeseries for each participant
    % Output: K-means parcellations for k=17 networks
    % 
    % Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License 2022.

    %To run: 
    %	 1. Claim computing resources using salloc (ex: `salloc --mem-per-cpu 300G --time 48:00:00 --x11`)
    %	 2. Load matlab module: `ml matlab/r2018b`
    %	 3. Enter the command `LD_PRELOAD= matlab`


    % Set initial vars
    project_dir = '/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_EVEN_GROUP/quant_metrics/kmeans';
    sublist = ["MSC01" "MSC02" "MSC03" "MSC04" "MSC05" "MSC06" "MSC07" "MSC08" "MSC09" "MSC10"];
    seslist = ["2" "4" "6" "8" "10"];

    % Load timeseries for each participant and run kmeans
    for sub = sublist
        %read in timeseries
        input_name = strcat('sub-',sub,'_concat_tseries.mat');
        full_input = fullfile(project_dir,input_name);
        input_series = load(full_input);

        %kmeans
        k = 17; %number of clusters (networks)
        distMet = 'sqeuclidean'; %distance metric = square Euclidean (default)
        maxIter = 100; %maximum number of iterations
        replicates = 1; %number of replications
        [idx, C, sumD, D] = kmeans(input_series.sub_series2, k, 'Distance', distMet, 'EmptyAction', 'singleton', 'MaxIter', maxIter, 'OnlinePhase', 'off', 'Replicates', replicates);   
        
            %convert NaN labels to 0
            idx(isnan(idx)) = 0; 

        %write out results
        file_name = fullfile(project_dir, strcat('sub-', sub, '_kmeans_k', num2str(k), '_distMet', distMet, '_reps', num2str(replicates), '_maxIter', num2str(maxIter)));
        save([char(file_name) '.mat'], 'idx', 'C', 'sumD', 'D');

        %save parc to lh_labels and rh_labels for parc2annot transform
        num_verts = 81924; %20484 vertices in fsaverage5 mesh, 81924 in fsaverage6
        rh_labels = idx(1:num_verts/2); %rh is first loaded, then lh is concatenated in concat_tseries.m
        lh_labels = idx((num_verts/2 + 1):end);
        
        out_name = fullfile(project_dir, strcat('sub-', sub, '_kmeans_k', num2str(k), '_labels.mat'));
        save(char(out_name), 'lh_labels', 'rh_labels');
        
    end

Expected Output 
***************

The output will be saved in two vectors within a MATLAB file: rh_labels and lh_labels, just like the Kong2019 individual parcellation output. From here, we can go ahead and perform the steps necessary for visualization. 