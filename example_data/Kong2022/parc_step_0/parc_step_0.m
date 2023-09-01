%Step 0 of CBIG Kong2022 Brain Parc Pipeline
%
%To run: 1. Open Matlab using salloc (ex: `salloc --mem-per-cpu 200G --time 2:00:00 --x11`)
%	 2. source your config file containing the $CBIG_CODE_DIR variable
%	 	-It might be helpful to `cd` to the $CBIG_CODE_DIR/stable_projects/brain_parcellation/Kong2019_MSHBM/step1... folder
% 	 3. Enter the command `ml matlab/r2018b`
%	 4. Enter the command `LD_PRELOAD= matlab`
%	 5. In Matlab: pull up this script and choose "Run"
%
%FYI, the data_list/fMRI_list lists should be formatted sub01_sess1, etc (such that there are no dashes or spaces between "sub" and "01" or "sess" and "1"
%
%Previously, recon-all and the CBIG preproc pipeline were run on these subjects. 
%Additionally, you must have the folder structure and text files with paths to your preproc output set up 
%See the CBIG example script CBIG_MSHBM_create_example_input_data.sh for details on formatting.
%The script "Create_parc_data.sh" has taken care of this.
%
%For questions, contact M. Peterson, Nielsen Brain and Behavior Lab

%Set tmpdir
     clear all
     setenv('TMPDIR','/fslgroup/fslg_spec_networks/compute/results/tmp');

%Part 1: Generate gradients
project_dir = '/fslgroup/grp_hcp/compute/HCP_analysis/Kong2022_parc_output_fs6_HCP_ALL/generate_gradients';

sub=["SUB"];

%Count number of text files that start with sub string
    filedir = strcat(project_dir, '/data_list/fMRI_list');
    code_dir=pwd;
    cd ( filedir )
    file = dir('*.txt');
    filenames = {file.name};
    sess = sum( ~cellfun(@isempty, strfind(filenames, sub)) )/2;

%Generate gradients on that number of sessions
    CBIG_repo = '/fslgroup/fslg_rdoc/compute/CBIG/stable_projects/brain_parcellation/Kong2022_ArealMSHBM/step0_generate_gradient_prior';
    cd ( CBIG_repo )

    CBIG_ArealMSHBM_generate_gradient('fsaverage6', project_dir, sub, num2str(sess));



%Troubleshooting help
%
%Error: fscanf cannot open... 
%	In this case, your paths somewhere are incorrect. Doublecheck your paths in the generate_profiles_and_ini_params/data_list/fMRI. Also, your project_dir could be incorrect
%   Also, the format of the data_list/fMRI_list text files names may be
%   incorrect
%
%Error: CBIG_MSHBM_generate_gradients function not found (or something like that)
%	You need to be in the step0 folder to run this script. If you are in a different directory, you will encounter this error.It may help to copy this script over to the script1 directory and then open matlab...

