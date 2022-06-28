Reorient a Nifti Image 
======================

This is particularly useful in the context of lesion-tracing, where images may come in different orientations.

Instructions
************

1. Check the current orientation of your image using fslorient:

.. code-block:: console

   $ fslorient -getorient image.nii
   
2. If the image is radiological, use fslorient to reorient the image:

.. code-block:: console

   $ fslorient -forceneurological image.nii

