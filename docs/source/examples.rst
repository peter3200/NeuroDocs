Miscellaneous
=============

This section is dedicated to the odds and ends that come up during imaging analyses.

.. _reorient:


Reorient a Nifti Image 
**********************

1. Check the current orientation of your image using fslorient:

.. code-block:: console

   $ fslorient -getorient image.nii
   
2. If the image is radiological, use fslorient to reorient the image:

.. code-block:: console

   $ fslorient -forceneurological image.nii


Download a Dataset from OpenNeuro
*********************************

1. Load python: 

.. code-block:: console
	
    $ ml python/3.6

2. Install the openneuro python package:

.. code-block:: console

    $ pip install openneuro-py

3. Identify the OpenNeuro accession number for your dataset. This can be found at the top of the webpage for a given dataset. Ex: ds000224 for the MSC dataset

4. Download the dataset using the accession number:

.. code-block:: console

    $ openneuro-py download --dataset=ds000224

5. Your download will begin. Files will be stored in the folder named after the dataset accession number.
