Kong2019 Parc Step 5
====================

Once individual parcellations have been generated, you may desire additional quantitative information about those parcellations. For this step, we will provide scripts for obtaining network surface area and dice coefficients.

Network Surface Area 
********************

To obtain network surface area for your individual parcellations, we will take 4 steps.
1. Parc2Annot. Convert .mat parcellations to .annot files. 
2. Freesurfer Statistics. Generate Freesurfer statistics for each subject (job and wrapper script). 
3. Grab Surface Area. Specifically obtain network surface area out of the statistics files.
4. Configure Surface Area. Add RH and LH surface area for each subject and place in a .mat file (usable as input for a Kernel Ridge Regression).

1.Parc2Annot 
------------

We will use MATLAB to convert the .mat parcellation files to .annot files. 

.. code-block:: matlab 

    % Wrapper script to turn parcellation files into FreeSurfer annotation
    % files. Then you can calculate surface area of parcellations!
    %
    % Assumes ind_parcellation output from Kong2019 CBIG pipeline.
    % Written by M. Peterson, Nielsen Brain and Behavior Lab
    %To run
    %	 1. Claim computing resources using salloc (ex: `salloc --mem-per-cpu 6G --time 2:00:00 --x11`)
    %    2. Source your CBIG config file to set up CBIG environment.	 
    %    3. Load matlab module: `ml matlab/r2018b`
    %	 4. Enter the command `LD_PRELOAD= matlab`

    %% HCPD
    project_dir = '/fslgroup/fslg_HBN_preproc/compute/HCPD_analysis/parc_output_fs6_HCPD/generate_individual_parcellations/ind_parcellation/test_set';
    out_dir = '/fslgroup/fslg_HBN_preproc/compute/HCPD_analysis/parc_output_fs6_HCPD/quant_metrics/MSHBM_vis';

    % Create output directory
    if(~exist(out_dir))
            mkdir(out_dir);
    end

    for sub = 1:616 %loop through each subject with a parcellation 
        sub_str = num2str(sub);
        sub_filename = strcat('Ind_parcellation_MSHBM_sub',sub_str,'_w200_MRF30_matched.mat'); %individual parcellation file names
        file = fullfile(project_dir,sub_filename);
        lh_name = strcat('sub-',sub_str,'_lh.annot');
        rh_name = strcat('sub-',sub_str,'_rh.annot');
        combo = strcat('sub-',sub_str);
        lh_output_file = fullfile(out_dir,lh_name);
        rh_output_file = fullfile(out_dir,rh_name);
        CBIG_SaveParcellationToFreesurferAnnotation(file, lh_output_file, rh_output_file);
    end

2.Freesurfer Stats 
------------------

Once we have the .annot files, we can use Freesurfer's mris_stats function to calculate network surface area. To do this, we will use a job and a wrapper script.

The wrapper script is as follows. 

.. code-block:: bash 

    #!/bin/bash

    code_dir=/fslgroup/fslg_autism_networks/compute/code/quant_metrics
    var=`date +"%Y%m%d-%H%M%S"`
    mkdir -p ~/logfiles/$var
    mkdir -p /fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2/quant_metrics #quant metrics folder where output will be stored

    for subj in 18 19; do #loop through each subject
        sbatch \
        -o ~/logfiles/${var}/output_${subj}.txt \
        -e ~/logfiles/${var}/error_${subj}.txt \
        ${code_dir}/freesurfer_mris_stats.sh \
        ${subj}
        sleep 1
    done

The job script is as follows. 

.. code-block:: bash 

    #!/bin/bash

    #SBATCH --time=00:10:00   # walltime
    #SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
    #SBATCH --nodes=1   # number of nodes
    #SBATCH --mem-per-cpu=16384M  # memory per CPU core

    # Compatibility variables for PBS. Delete if not needed.
    export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
    export PBS_JOBID=$SLURM_JOB_ID
    export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
    export PBS_QUEUE=batch

    # Set the max number of threads to use for programs using OpenMP.
    export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

    # LOAD ENVIRONMENTAL VARIABLES
    export FREESURFER_HOME=/fslhome/mpeter55/compute/research_bin/freesurfer
    source $FREESURFER_HOME/SetUpFreeSurfer.sh

    subjid=$1
    export SUBJECTS_DIR=/fslgroup/fslg_autism_networks/compute/data/renamed #location of freesurfer output
    CBIG_OUTPUT_DIR=/fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2

    # INSERT CODE, AND RUN YOUR PROGRAMS HERE
        # left hemisphere
    mris_anatomical_stats \
    -a /fslgroup/fslg_autism_networks/compute/data/renamed/sub-${1}/anat/sub-${1}/sub-${1}_lh.annot \
    -f /fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2/quant_metrics/sub-${1}_LH_SA.csv \
    -b sub-${1}/anat/sub-${1} lh


        # right hemisphere
    mris_anatomical_stats \
    -a /fslgroup/fslg_autism_networks/compute/data/renamed/sub-${1}/anat/sub-${1}/sub-${1}_rh.annot \
    -f /fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2/quant_metrics/sub-${1}_RH_SA.csv \
    -b sub-${1}/anat/sub-${1} rh  

    #Note: -a = path to annotation file, -f is path to output file, -b is tabular
    #output (to your logfile set up in the job script)
    #followed by the path to the subject's recon-all output
    #and then the hemisphere.

3.Grab Surface Area 
-------------------

Once the stats have been calculated, we are going to go ahead and grab the specific values we are interested in, namely network surface area.

.. code-block:: bash 
    
    #!/bin/bash

    genDir=/fslgroup/fslg_HBN_preproc/compute
    subDir=${genDir}/parc_test_output_MP2/quant_metrics/network_SA #output directory

    mkdir -p ${subDir}
    mv ${genDir}/parc_test_output_MP2/quant_metrics/sub*.csv ${subDir}

    #Remove the first 60 lines in the .csv file generated in Step 2
    for i in 18	19; do #loop through each subject
        sed -i '1,60d' ${subDir}/sub-${i}_LH_SA.csv
        sed -i '1,60d' ${subDir}/sub-${i}_RH_SA.csv
    done

    #Extract SA (3rd column) and add as a row to a group csv file
    for i in 18	19; do #loop through each subject
        #LH
        cat ${subDir}/sub-${i}_LH_SA.csv | sed -r 's/\s+/ /g' > ${subDir}/sub-${i}_LH_SA_s.csv
        cat ${subDir}/sub-${i}_LH_SA_s.csv | cut -d " " -f3 > ${subDir}/sub-${i}_LH_SA3.csv
        cat ${subDir}/sub-${i}_LH_SA3.csv | awk -v RS= -v OFS="\t" '{$1 = $1} 1' >> ${subDir}/LH_SA.txt
        sed -i 1i"lh" ${subDir}/sub-${i}_LH_SA3.csv 
        #RH
        cat ${subDir}/sub-${i}_RH_SA.csv | sed -r 's/\s+/ /g' > ${subDir}/sub-${i}_RH_SA_s.csv
        cat ${subDir}/sub-${i}_RH_SA_s.csv | cut -d " " -f3 > ${subDir}/sub-${i}_RH_SA3.csv 
        cat ${subDir}/sub-${i}_RH_SA3.csv | awk -v RS= -v OFS="\t" '{$1 = $1} 1' >> ${subDir}/RH_SA.txt	
        sed -i 1i"rh" ${subDir}/sub-${i}_RH_SA3.csv
    done 

.. note:: This step generated group LH and RH .csv files. The next step is to calculate the total surface area for each network.
  
4.Configure Surface Area 
------------------------

The purpose of this step is to take the previously calculated surface area for each network and convert it into a usable form. To do this, we will use python. 

.. code-block:: bash

    ml python/3.6
    python configure_SA.py 

The contents of configure_SA.py are shown below.

.. code-block:: python  

    #!/usr/bin/env python
    # Purpose: Create .mat input of network SA for the 17 networks 
    # Input: single-column .csv files with SA for each hemisphere. 
    # Output: .mat struct for each individual's SA for the 17 networks. Usable input for KRR.
    # Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License (2021)

    #load packages
    from pathlib import Path
    import time
    import os
    from os.path import dirname, join as pjoin
    import sys
    import scipy.io #loads .mat files
    import csv
    import numpy as np
    import pandas as pd

    #List of test set subjids
    test_set = [18, 19]

    #for each subject, load .csv input files and add the SAs together to get a total SA for each network
    for sub1 in test_set: 
        #path to rh input files
        data_dir: str="/fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2/quant_metrics/network_SA"
        rh_name = "sub-" + str(sub1) + "_RH_SA3.csv"
        rh_sub = pjoin(data_dir, rh_name)

        #path to lh input files
        lh_name = "sub-" + str(sub1) + "_LH_SA3.csv"
        lh_sub = pjoin(data_dir, lh_name)
        
        csv_file_list = [rh_sub, lh_sub] #combine the SAs from the two CSV files
        list_of_dataframes = [] #create empty list
        
        for filename in csv_file_list:
            list_of_dataframes.append(pd.read_csv(filename)) #actually appends one list to the other

        merged_df = pd.concat(list_of_dataframes, axis=1) #concatenates the two lists into a pandas format
        sum_column = merged_df["rh"] + merged_df["lh"] #add the surface areas from the right and left hemispheres
        merged_df["total"] = sum_column #add this column to the dataset
        
        running_list = []	#creates empty placeholder list
        running_list = list(merged_df["total"])	#saves the "total" column into the list
        #del running_list[0:1] #removes the first network (NONAME 0 1 1 1 on CLUT)
        r_arr = np.vstack(np.array(running_list)) #transpose the array from horizontal to vertical

        mdic = {"network_SA": r_arr} #Create matlab dictionary datatype
        mat_name = "sub" + str(sub1) + "_total_SA.mat"
        full_mat = pjoin(data_dir, mat_name)
        scipy.io.savemat(full_mat, mdic) #Total SA as a single .mat file for each subject

This wraps up the surface area calculations!

Dice Coefficient 
****************

What is a dice coefficient? It is a statistic that measures similarity or overlap between two datasets. The official formula is (2(X join Y))/(X+Y), where X join Y consists of the number of commonalities between X and Y. 

This is a very useful index when we want to estimate the overlap in parcellation labels between two subjects, an individual and the group parcellation, or between to parcellations from the same individual (in the case that you are determining test-retest reliability for example). Here we will provide code for calculating a matrix of dice coefficients (each individual by every other individual then averaged across each network), test-retest dice coefficients (individual X by individual X), and individual-group dice coefficients.

Dice Matrix 
-----------

This matrix of averaged dice coefficients can be used as input to a Kernel Ridge Regression. To create this matrix, we will use python. 

.. code-block:: python 

    #!/usr/bin/env python
    # Purpose: Create 3D matrix of dice coefficients, KxKxN where K = subject and N = network, all are test subjects! 
    # Input: ind_parcellation output from Kong2019 pipeline
    # Output: matrices (initially 17 30x30 2D matrices, followed by 1 30x30 matrix with averaged dice coefficients)
    # Note: Users may need to run 'which python' and paste the correct path following the shebang on line one.
    # Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License (2021)

    from pathlib import Path
    import time
    import os
    from os.path import dirname, join as pjoin
    import sys
    import scipy.io #loads .mat files
    import csv
    import numpy as np

    # create function to get index positions
    def get_index_positions(list_of_elems, element):
        index_pos_list = []
        index_pos = 0
        while True:
            try:
                index_pos = list_of_elems.index(element, index_pos)
                index_pos_list.append(index_pos)
                index_pos += 1
            except ValueError as e:
                break
        return index_pos_list


    # Create 2D matrices of the dice coefficient (30x30) for each network
    for network in range(0,18): #Range must be set to actual number of networks +1
        count = 0 #Counter to keep track of which subject combination we are on within each network
        for sub1 in range(1,31):
            count += 1
            for sub2 in range(1,31):
                # path to test_set subjects
                test_dir: str="/fslgroup/fslg_rdoc/compute/parc_test_output_MP/generate_individual_parcellations/ind_parcellation/test_set"
                test_name = "Ind_parcellation_MSHBM_sub" + str(sub1) + "_w60_MRF30.mat"
                test_sub = pjoin(test_dir, test_name)
                test_file = scipy.io.loadmat(test_sub) #Load first sub .mat file
                test_rh = np.squeeze(test_file['rh_labels']) 
                test_rh_list = test_rh.tolist()			
                test_lh = np.squeeze(test_file['lh_labels'])
                test_lh_list = test_lh.tolist()
                # combine Rh and Lh labels
                test_comb2 = np.append(test_rh_list,test_lh_list) #Combine RH and LH labels files
                test_comb = test_comb2.tolist()
        
                # path to second subject
                sec_dir: str="/fslgroup/fslg_rdoc/compute/parc_test_output_MP/generate_individual_parcellations/ind_parcellation/test_set"
                sec_name = "Ind_parcellation_MSHBM_sub" + str(sub2) + "_w60_MRF30.mat"
                sec_sub = pjoin(sec_dir, sec_name)
                sec_file = scipy.io.loadmat(sec_sub)
                sec_rh = np.squeeze(sec_file['rh_labels'])
                sec_rh_list = sec_rh.tolist()
                sec_lh = np.squeeze(sec_file['lh_labels'])
                sec_lh_list = sec_lh.tolist()
                # Combine Rh and Lh labels
                sec_comb2 = np.append(sec_rh_list,sec_lh_list)
                sec_comb = sec_comb2.tolist()

                #find total and common vertices between subjects
                test_tot = test_comb.count(network) #Total vertices for $network in test subject (sub1)
                sec_tot = sec_comb.count(network) #Total vertices for $network for second subject (sub2)

                index_pos_list = get_index_positions(test_comb, network) #Get positions/order for $network for sub1
                test_pos_list = index_pos_list 
                index_pos_list = None

                index_pos_list = get_index_positions(sec_comb, network) #Get positions/order for $network for sub2
                sec_pos_list = index_pos_list 
                index_pos_list = None

                common = len([x for x in test_pos_list if x in sec_pos_list]) #Compare positions for $network for both subjects
                denominator = sec_tot + test_tot #Combine total number of vertices with $network
                dice = (2 * common) / denominator if denominator != 0 else 0  # calculate dice coefficient

                if sub2==1:
                    running_list = []
                    running_list.append([dice])
                else:
                    running_list.append([dice])

            #For each Sub1, add a row (a list) to network list
            if sub1==1:
                df_list = []
                df_list.append(running_list)
            else:
                df_list.append(running_list)
            
        #For each network, write a .npy file
        file_name = "arr" + str(network) + ".npy"
        np.save(file_name, df_list)

        
    # Load the 17 matrices and concatenate them into a 3D numpy matrix
    arr0 = np.load('arr0.npy')
    arr1 = np.load('arr1.npy')
    arr2 = np.load('arr2.npy')
    arr3 = np.load('arr3.npy')
    arr4 = np.load('arr4.npy')
    arr5 = np.load('arr5.npy')
    arr6 = np.load('arr6.npy')
    arr7 = np.load('arr7.npy')
    arr8 = np.load('arr8.npy')
    arr9 = np.load('arr9.npy')
    arr10 = np.load('arr10.npy')
    arr11 = np.load('arr11.npy')
    arr12 = np.load('arr12.npy')
    arr13 = np.load('arr13.npy')
    arr14 = np.load('arr14.npy')
    arr15 = np.load('arr15.npy')
    arr16 = np.load('arr16.npy')
    arr17 = np.load('arr17.npy')
    comb_array = np.array((arr0, arr1, arr2, arr3, arr4, arr5, arr6, arr7, arr8, arr9, arr10, arr11, arr12, arr13, arr14, arr15, arr16, arr17), dtype=float) #Create 3D combined matrix

    #Average coefficients across networks (yields a KxK matrix that forms kernel for KRR)
    avg_dice = np.mean(comb_array, axis=0) 
    avg_name = "avg_dice_matrix.npy"

    #Save output 
    np.save(avg_name, avg_dice) #Save as .npy
    mdic = {"avg_dice": avg_dice} #Create matlab dictionary datatype
    scipy.io.savemat("avg_dice.mat", mdic) #Save avg matrix as .mat matrix

Test-Retest Dice Coefficients 
-----------------------------

If you are developing a pipeline or testing the reliability of a known pipeline, it can be very informative to examine the test-retest reliability. One example use case may be running the parcellation pipeline on all of the even runs for a subject separate from all of the odd runs from that same subject. We can then look at the overlap in network assignment between the odd and even runs (the dice coefficient!). A higher dice coefficient is indicative of greater overlap (higher reliability).

To do this, we will use python.

.. code-block:: python 

    #!/usr/bin/env python
    # Purpose: Create a .csv file of Nx17 dice coefficients to assess MSHBM test-retest reliability
    # Input: ind_parcellation output from Kong2019 pipeline
    # Output: 1 Nx17 .csv file with dice coefficients
    # Note: Users may need to run 'which python' and paste the correct path following the shebang on line one.
    # Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License (2021)

    from pathlib import Path
    import time
    import os
    from os.path import dirname, join as pjoin
    import sys
    import scipy.io #loads .mat files
    import csv
    import numpy as np
    import pandas as pd

    # create function to get index positions
    def get_index_positions(list_of_elems, element):
        index_pos_list = []
        index_pos = 0
        while True:
            try:
                index_pos = list_of_elems.index(element, index_pos)
                index_pos_list.append(index_pos)
                index_pos += 1
            except ValueError as e:
                break
        return index_pos_list

    # Create 2D matrices of the dice coefficient for each network
    count=0
    for sub1 in range(1,11):
        for network in range(0,18): #Range must be set to actual number of networks +1
            count=(count+1)
            # set sub name
            sub=str(sub1)
            new_sub = sub.zfill(2)
            sub_name = "MSC" + str(new_sub)

            # path to test_set subjects
            test_dir: str="/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_EVEN_GROUP/generate_individual_parcellations/ind_parcellation/test_set"
            test_name = "Ind_parcellation_MSHBM_sub" + str(sub1) + "_w200_MRF30_matched.mat"
            test_sub = pjoin(test_dir, test_name)
            test_file = scipy.io.loadmat(test_sub) #Load first sub .mat file
            test_rh = np.squeeze(test_file['rh_labels']) 
            test_rh_list = test_rh.tolist()			
            test_lh = np.squeeze(test_file['lh_labels'])
            test_lh_list = test_lh.tolist()
            # combine Rh and Lh labels
            test_comb2 = np.append(test_rh_list,test_lh_list) #Combine RH and LH labels files
            test_comb = test_comb2.tolist()
        
            # path to second subject
            sec_dir: str="/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_ODD_GROUP/generate_individual_parcellations/ind_parcellation/test_set"
            sec_name = "Ind_parcellation_MSHBM_sub" + str(sub1) + "_w200_MRF30.mat"
            sec_sub = pjoin(sec_dir, sec_name)
            sec_file = scipy.io.loadmat(sec_sub)
            sec_rh = np.squeeze(sec_file['rh_labels'])
            sec_rh_list = sec_rh.tolist()
            sec_lh = np.squeeze(sec_file['lh_labels'])
            sec_lh_list = sec_lh.tolist()
            # Combine Rh and Lh labels
            sec_comb2 = np.append(sec_rh_list,sec_lh_list)
            sec_comb = sec_comb2.tolist()

            #find total and common vertices between subjects
            test_tot = test_comb.count(network) #Total vertices for $network in test subject (sub1)
            sec_tot = sec_comb.count(network) #Total vertices for $network for second subject (sub2)

            index_pos_list = get_index_positions(test_comb, network) #Get positions/order for $network for sub1
            test_pos_list = index_pos_list 
            index_pos_list = None

            index_pos_list = get_index_positions(sec_comb, network) #Get positions/order for $network for sub2
            sec_pos_list = index_pos_list 
            index_pos_list = None

            common = len([x for x in test_pos_list if x in sec_pos_list]) #Compare positions for $network for both subjects
            denominator = sec_tot + test_tot #Combine total number of vertices with $network
            dice = (2 * common) / denominator if denominator != 0 else 0  # calculate dice coefficient

            if count==1:
                runningList = [[sub_name, network, dice]] 
                df = pd.DataFrame(runningList, columns=['SUBJID', 'Network', 'Dice'])
            else:
                runningList = [[sub_name, network, dice]]
                df = df.append(pd.DataFrame(runningList, columns=['SUBJID', 'Network', 'Dice']), ignore_index=True)

    #Save the dataframe as .csv
    r_name = "retest_MSHBM_LONG_dice_220810.csv" #file name
    df.to_csv(r_name, index=True, index_label=None) #save dataframe to csv

Group-Individual Dice 
---------------------

One additional piece of information that may be useful is a quanitative estimate of the overlap between group labels and individual parcellation labels. 

To do this, we will again use python.

.. code-block:: python 

    #!/usr/bin/env python
    # Purpose: Create a .csv file of Nx17 dice coefficients to assess MSHBM test-retest reliability
    # Input: ind_parcellation output from Kong2019 pipeline
    # Output: 1 Nx17 .csv file with dice coefficients
    # Note: Users may need to run 'which python' and paste the correct path following the shebang on line one.
    # Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License (2021)

    from pathlib import Path
    import time
    import os
    from os.path import dirname, join as pjoin
    import sys
    import scipy.io #loads .mat files
    import csv
    import numpy as np
    import pandas as pd

    # create function to get index positions
    def get_index_positions(list_of_elems, element):
        index_pos_list = []
        index_pos = 0
        while True:
            try:
                index_pos = list_of_elems.index(element, index_pos)
                index_pos_list.append(index_pos)
                index_pos += 1
            except ValueError as e:
                break
        return index_pos_list

    # Create 2D matrices of the dice coefficient for each network
    count=0
    for sub1 in range(1,11):
        for network in range(0,18): #Range must be set to actual number of networks +1
            count=(count+1)
            # set sub name
            sub=str(sub1)
            new_sub = sub.zfill(2)
            sub_name = "MSC" + str(new_sub)

            # path to test_set subjects
            test_dir: str="/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_ALL/generate_individual_parcellations/ind_parcellation/test_set"
            test_name = "Ind_parcellation_MSHBM_sub" + str(sub1) + "_w200_MRF30_matched.mat"
            test_sub = pjoin(test_dir, test_name)
            test_file = scipy.io.loadmat(test_sub) #Load first sub .mat file
            test_rh = np.squeeze(test_file['rh_labels']) 
            test_rh_list = test_rh.tolist()			
            test_lh = np.squeeze(test_file['lh_labels'])
            test_lh_list = test_lh.tolist()
            # combine Rh and Lh labels
            test_comb2 = np.append(test_rh_list,test_lh_list) #Combine RH and LH labels files
            test_comb = test_comb2.tolist()
        
            # path to second subject
            sec_dir: str="/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_ALL/generate_profiles_and_ini_params/"
            sec_name = "group.mat"
            sec_sub = pjoin(sec_dir, sec_name)
            sec_file = scipy.io.loadmat(sec_sub)
            sec_rh = np.squeeze(sec_file['rh_labels'])
            sec_rh_list = sec_rh.tolist()
            sec_lh = np.squeeze(sec_file['lh_labels'])
            sec_lh_list = sec_lh.tolist()
            # Combine Rh and Lh labels
            sec_comb2 = np.append(sec_rh_list,sec_lh_list)
            sec_comb = sec_comb2.tolist()

            #find total and common vertices between subjects
            test_tot = test_comb.count(network) #Total vertices for $network in test subject (sub1)
            sec_tot = sec_comb.count(network) #Total vertices for $network for second subject (sub2)

            index_pos_list = get_index_positions(test_comb, network) #Get positions/order for $network for sub1
            test_pos_list = index_pos_list 
            index_pos_list = None

            index_pos_list = get_index_positions(sec_comb, network) #Get positions/order for $network for sub2
            sec_pos_list = index_pos_list 
            index_pos_list = None

            common = len([x for x in test_pos_list if x in sec_pos_list]) #Compare positions for $network for both subjects
            denominator = sec_tot + test_tot #Combine total number of vertices with $network
            dice = (2 * common) / denominator if denominator != 0 else 0  # calculate dice coefficient

            if count==1:
                runningList = [[sub_name, network, dice]] 
                df = pd.DataFrame(runningList, columns=['SUBJID', 'Network', 'Dice'])
            else:
                runningList = [[sub_name, network, dice]]
                df = df.append(pd.DataFrame(runningList, columns=['SUBJID', 'Network', 'Dice']), ignore_index=True)

    #Save the dataframe as .csv
    r_name = "retest_MSHBM_INDIVIDUAL_GROUP_dice_220810.csv" #file name
    df.to_csv(r_name, index=True, index_label=None) #save dataframe to csv


