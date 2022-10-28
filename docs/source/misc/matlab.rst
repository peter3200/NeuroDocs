Using MATLAB in a Supercomputing Environment
============================================

This tutorial will walk through how to use the MATLAB GUI (graphical user interface) in a RHEL 8 Linux OS environment. 

1. Load MATLAB. Version r2018b is recommended for CBIG scripts.

.. code-block:: bash

    module load matlab/r2018b

2. Request an `salloc` job. This is where you request an amount of RAM in gigabytes, the amount of time you expect the job to take in hours, and indicate that you would like x11 forwarding (graphical capabilities). 

.. code-block:: bash

    salloc --mem-per-cpu 50G --time 4:00:00 --x11

3. If using CBIG scripts, source your configuration file

.. code-block:: bash 

    source /fslgroup/fslg_rdoc/compute/test_scripts/parc_scripts/CBIG_preproc_tested_config_funconn.sh 

4. Set $LD_PRELOAD. Note the space between "=" and "matlab".

.. code-block:: bash

    LD_PRELOAD= matlab 

The MATLAB GUI will now launch. You can expect the initialization to take ~4 minutes.

