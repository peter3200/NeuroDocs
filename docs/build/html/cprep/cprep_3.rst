CBIG2016 Preproc Step 3
========================

Orientation to Preproc Output
*****************************

The CBIG2016 preprocessing pipeline can be configured to have many steps and subsequently many output files and folders. The basic structure of the output for a single subject will look like the following:

.. code-block:: bash

    >>tree sub-AA0002 -L 2 #use the `tree` command to view the contents of a folder
    sub-AA0002
    -- sub-AA0002
        |-- FC_metrics
        |-- bold
        |-- logs
        |-- qc
        |-- surf
        |-- vol

Within each subject folder, there are these six standard headings: FC_metrics, bold, logs, qc, surf, and vol. Here is a more detailed description of each.

* FC_metrics. This folder contains a functional connectivity matrix for the subject (419x419 ROIs) and lists of the associated ROIs.

* bold. This folder contains the input BOLD fMRI files. 

* logs. This folder contains the logfiles from processing. If a subject failed to complete processing, search the logs to find out why! It is helpful to start with CBIG_preproc_fMRI_preprocess.log to identify which step caused the error and then go to that step's specific logfile for the details. 

* qc. This folder contains files relevant to quality control, including QC greyplots, framewise displacement (FD) and DVARS data for each BOLD input file.

* surf. This folder contains surface-project fMRI data (RH and LH) for each input BOLD file. The naming scheme of this output depends on your specific input parameters (ex: if you specify fsaverage5 in the config file, then the output will contain 'fs5' in the filenames).

* vol. This folder contains MNI masks.

Relevant Output for Kong2019 MS-HBM Pipeline
********************************************

The Kong2019 MSHBM parcellation pipeline requires CBIG2016 preproc output. In Generate_data_step_0.sh (a precursor for the first parcellation step), you will specific the surface output files (found in sub/sub/surf). You will need to adjust the Generate_data_step_0.sh script to accommodate any changes made to the config file in order to correctly direct the parc scripts to this output.