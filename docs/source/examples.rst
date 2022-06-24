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

