Seed-based Analysis Step 2
==========================

Now that we've obtained a full-surface correlation matrix (potentially z-transformed), the next step is to convert this massive matrix into a surface file (cifti format).

What is Cifti Format?
*********************

There are several subtypes of cifti files, but they all have one thing in common--they represent data on the surface without being constrained to surface location. This means that any cifti file with X number of vertices can be displayed or overlaid on a surface structure file with that same number of vertices even if that surface file is the pial surface, inflated, or very inflated! 

For this tutorial, we will be working with .dconn.nii files, which stores connectivity values. For more information on other types of cifti files and their uses, we highly recommend the layman's guide to working with cifti files (https://mandymejia.com/2015/08/10/a-laymans-guide-to-working-with-cifti-files/). 

Correlation To Cifti
********************

To make this happen, we are going to load the following script in Matlab! This script takes advantage of the CBIG function to write a correlation matrix into .dconn.nii cifti format. 

.. code-block:: matlab

    % Purpose: Convert full surface correlation matrices into CIFTI surface
    % files for HCP Workbench viewing
    % Input: Full-surface correlation matrix averaged across runs 
    % (consider using CBIG full surface correlation script)
    % Output: 1 CIFTI file per individual.
    %
    % Written by M. Peterson, Nielsen Brain and Behavior Lab

    %To run: 
    %	 1. Claim computing resources using salloc (ex: `salloc --mem-per-cpu 300G --time 2:00:00 --x11`)
    %    2. Source your CBIG config file to set up CBIG environment.	 
    %    3. Load matlab module: `ml matlab/r2018b`
    %	 4. Enter the command `LD_PRELOAD= matlab`


    % prep for usage
    clear all
    setenv('TMPDIR','/fslgroup/fslg_spec_networks/compute/results/tmp')

    % Set project and subject variables
    project_dir = '/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_ALL/quant_metrics/FC_matrices';
    sublist1 = ["MSC01" "MSC02" "MSC03" "MSC04" "MSC05" "MSC06" "MSC07" "MSC08" "MSC09" "MSC10"];

    % Loop through each subject and call CBIG_write_correlation_matrix script
    for sub = sublist1
        %input file
        filename = strcat('sub-', sub, '_avg_FC.mat');
        fullname = fullfile(project_dir, filename);
        load(fullname);
        %output file
        output_name = strcat('sub-', sub, '_avg_FC');
        %call CBIG script
        CBIG_write_correlation_matrix_into_ciftiformat(ind_avg, output_name, project_dir); %automatically saved as a .dconn.nii file
    end

.. note:: Matlab will require a lot of RAM to load in the large correlation matrix and write out an equally large cifti file. Be sure to request ~300G of memory in your `salloc` job.

The next step is to work with the file in workbench!