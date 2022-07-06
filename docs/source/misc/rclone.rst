Rclone
======

Overview
********

The primary purpose of rclone is to transfer files between the supercomputer and the cloud (Box in this case). Rclone is really simple to use and setup, and can make your life much easier. Furthermore, there are settings to automatically backup files on the supercomputer to the cloud, which will ensure that you never lose files in a supercomputer outage again!

Setup 
*****

To get setup, follow the instructions on the Office of Research Computing `website <https://rc.byu.edu/wiki/?id=Rclone>`__.

.. note:: If you run into problems, don't hesitate to open a support ticket!

Usage
*****

Once you've got rclone setup, you can start enjoying its many functions! Full usage notes can be found with the rclone `documentation <https://rclone.org/docs/>`__.

.. note:: The rclone module will need to be loaded before use on the superocmputer: ``ml rclone``.

Basic Syntax
~~~~~~~~~~~~

Rclone commands follow a basic structure: 

.. code-block:: console
    
    $ [options] subcommand <parameters> <parameters...>

Copy Files to Box
~~~~~~~~~~~~~~~~~~~~~

To copy files from the supercomputer to Box, use:

.. code-block:: console 

    $ rclone copy ./file.txt box:/Full/Path/To/Folder  #order of paths is ./origin ./destination

The same command structure is used to copy over directories. 

Copy Files from Box
~~~~~~~~~~~~~~~~~~~~~~~

To copy files from Box to the supercomputer, the syntax is very similar with a reversal in paths:

.. code-block:: console 

    $ rclone copy box:/Full/Path/To/Folder/file.txt ./ #order of paths is ./origin ./destination

Sync
~~~~

If you've copied over most of a directory to the cloud but have since added additional files, rather than copying over every file, you can ``sync`` the directory. This is particularly useful for backing up folders with thousands of files.

.. code-block:: console 

    $ rclone sync ./folder box:/folder 

Transfer
~~~~~~~~

If you are done working with a dataset on the supercomputer and are running out of disk space, you can transfer your dataset to Box:

.. code-block:: console
        
    $ tar -czf dataset.tar.gz ~/compute/dataset #compress dataset
    $ rclone move dataset.tar.gz box:mydir/dataset.tar.gz #transfer dataset

Automatic Backup
~~~~~~~~~~~~~~~~

To set up automatic backups, you can create an rclone script and use ``cron`` to run it on a regular basis (weekly, daily, monthly, etc.)

.. code-block:: bash 

    #Example rclone script
    module load rclone
    PRIMARY="box:backup/dataset/primary"
    OLD="backup/dataset/old/dataset-$(date +%F_%H-%M)"
    rclone sync "$HOME/compute/dataset" "$PRIMARY" --backup-dir "$OLD"

We can now implement ``cron`` to run this script on a regular basis:

.. code-block:: bash 

    #Edit crontab
    $ crontab -e 

    #Now enter something along the lines of:
    $ 0 X * * Y bash /path/to/do_rclone_backup.sh 
    #(replacing X with an hour, 0-24, and Y with a day of the week, 0-6)

For a more detailed crontab tutorial, please see this `guide <https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/>`__.
