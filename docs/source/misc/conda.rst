Installing Conda 
================

Conda is package manager for python and can be helpful in setting up reproducible environments. The `CBIG repo <https://github.com/ThomasYeoLab/CBIG/tree/master/setup/python_env_setup#quick-installation-for-linux>`__ uses conda to setup their python environment. The following instructions are for Linux setup.


1. Download the setup file
 
.. code-block:: bash

    wget "https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh"

2. Run the set up file 

.. code-block:: bash 

    sh Anaconda3-2022.10-Linux-x86_64.sh  

3. Setup the conda environment folling `CBIG instructions <https://github.com/ThomasYeoLab/CBIG/tree/master/setup/python_env_setup#quick-installation-for-linux>`__ for Linux. 

.. code-block:: bash 

    cd $CBIG_CODE_DIR/setup/python_env_setup
    bash CBIG_python_env_generic_setup.sh

4. Test the installation. First logout of the shell and then log back in before testing. 

.. code-block:: bash 

    source activate CBIG_py3
    python -m pytest $CBIG_CODE_DIR/setup/python_env_setup/tests/CBIG_python_env_setup_unit_test.py

