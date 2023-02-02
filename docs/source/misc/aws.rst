Implementing AWS CLI
====================

In downloading archival datasets from large consortia, you may encounter Amazon's S3 storage service and need to retrieve data from an S3 "bucket". The purpose of this guide is to walk you through how to install the Amazon Web Services (AWS) command-line interface (CLI) and copy data from an S3 bucket.

Install the CLI
***************

For the latest version and installation directions, please see the Amazon guide at https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

As of February 2023, the latest version is 2 and the following directions apply in the bash command line.

.. code-block:: bash
    
    #Retrieve the zip file from the internet
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    #Unzip the file
    unzip awscliv2.zip

    #Install the CLI (set to your home directory, but change the paths as needed)
    ./aws/install -i /fslhome/netid/aws-cli -b /fslhome/netid/bin
    #Test the installation by asking for the version number
    /fslhome/netid/bin/aws --version

After installing and testing the CLI, the next step is to configure it by setting your special access ID and secret. To obtain the access ID and secret, you will need to obtain a free AWS account (simply Google this and follow the setup steps online). 

Once you have the access ID and secret, you will need to input these to get access to the S3 bucket. More thorough configuration directionis can be found online (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html). 

.. code-block:: bash 

    #Initial configuration
    /fslhome/netid/bin/aws configure
        #Input the access ID and secret as prompted

    #Check your configuration
    /fslhome/netid/bin/aws configure list

Copying Data from S3
********************

To copy over data, follow the command structure outlined below. 

.. code-block:: bash 

    /fslhome/netid/bin/aws s3 cp s3://BUCKETNAME/PATH/TO/FOLDER LocalFolderName --recursive

To provide a practical example, we will use the Natural Scenes Dataset, which is exclusively hosted on AWS S3. 

.. code-block:: bash 

    #Download the raw data 
    /fslhome/netid/bin/aws s3 cp s3://natural-scenes-dataset/nsddata_rawdata . --recursive 

    #Download a specific subject's raw data 
    /fslhome/netid/bin/aws s3 cp s3://natural-scenes-dataset/nsddata_rawdata/sub-07 ./sub-07 --recursive 
    