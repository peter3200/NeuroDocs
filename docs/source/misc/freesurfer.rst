Installing Freesurfer
=====================

Overview
********

Freesurfer is an enormously helpful open-source package used for analysis of structural, functional, and diffusion data. The primary functionality, surface reconstruction (recon-all), is integrated into the fMRIprep pipeline. 

Installation
************

1. Download Freesurfer for Linux using wget:

.. code-block:: console 

    $ cd research_bin
    $ wget "https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.2.0/freesurfer-linux-centos6_x86_64-7.2.0.tar.gz"

For reference, the downloads page is: `https://surfer.nmr.mgh.harvard.edu/fswiki/rel7downloads`. 

2. Extract the gzipped file using `tar`:

.. code-block:: console 

    $ tar -xzvf freesurfer-linux-centos6_x86_64-7.2.0.tar.gz

3. Update your environment

.. code-block:: console 

    $ nano ~/.bash_profile

Within the text editor, add the following:

.. code-block:: bash 

    ## FreeSurfer 
    export FREESURFER_HOME=~/research_bin/freesurfer 
    source $FREESURFER_HOME/SetUpFreeSurfer.sh 

Save your changes and update the environment:

.. code-block:: console 

    $ source ~./bash_profile 

4. Activate your version of FreeSurfer by downloading the license and placing it in $FREESURFER_HOME.

a. Complete the registration form `online <https://surfer.nmr.mgh.harvard.edu/registration.html>`__.

b. Transfer the license to your supercomputer account:

.. code-block:: console 

    $ scp license.txt NETID@ssh.rc.byu.edu:/fslhome/NETID 

In your supercomputer account, move the license.txt file to $FREESURFER_HOME

    $ mv license.txt $FREESURFER_HOME 

5. Test your installation. To verify that it's working, try the following command: 

.. code-block:: console 

    $ mris_convert 

This should spit out the usage the command. 