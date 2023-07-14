CBIG2016 Preproc  Step 0
========================

Overview
********

Step 0 is all about downloading the CBIG repo and getting things setup generally before we start implementing specific pipelines, such as the preprocessing pipeline. To do this, we are going to clone the repo and follow the instructions to configure our environment to be compatible. Additionally, we will download the necessary software to implement the pipelines.

Cloning the Repo 
****************

All of the relevant CBIG code can be found on `Github <https://github.com/ThomasYeoLab/CBIG>`__. To download it on the supercomputer, we will use ``git``. 

.. code-block:: console

    $ cd research_bin
    $ git clone https://github.com/ThomasYeoLab/CBIG.git

Configuration
*************

After the cloning finishes, you can go into the /setup folder and find a README.md file. This file contains instructions for configuring the environment.

We are going to first copy their example configuration script and set the paths to the necessary software packages.

.. code-block:: console 

    $ cp <cbig-directory>/setup/CBIG_sample_config.sh ~/CBIG_EDITED_config.sh
    $ nano CBIG_EDITED_config.sh 

Now, we are going to set the paths to specific software versions required by CBIG. 

Once you have edited the config script, you can go ahead and use it to update your environment:

.. code-block:: console 

    $ source CBIG_EDITED_config.sh 

.. note:: Before using any CBIG scripts, be sure to ``source`` the edited config script in order to correctly setup your environment.

Updating the Repo
*****************

Occasionally, CBIG will release updates to their code. To know when this happens, join the CBIG users `group <https://groups.google.com/forum/#!forum/cbig_users/join>`__. 

To update the repo, use the following commands:

.. code-block:: console 

    $ cd $CBIG_CODE_DIR
    $ git checkout master
    $ git pull origin master

Software Requirements 
*********************

To use the CBIG code successfully, we recommend installing the necessary versions of CBIG software. However, in some cases, these older versions resulted faulty parcelations (Kong2019 MSHBM pipeline). Using the example subjects included with the Kong2019 pipeline, we have verified that the use of some newer software versions can result in the same or very similar parcellations. As of July 2022, software versions are as follows:

* Freesurfer 7.1.1
* FSL 6.0.4
* Workbench 1.4.2
* AFNI 20.2.18
* ANTs 2.2.0 (old) - Important to have this version! 
