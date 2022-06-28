Read The Docs
=============

Background
**********

Thorough documentation is really important to moving open science forward. This page is a basic guide to getting started with Github and ReadTheDocs. Github is wonderful for storing and sharing code and ReadTheDocs integrates with Github and Sphinx to generate automatically updating documentation for that code. Convinced?

Learn by Doing 
**************

The most helpful tutorial for getting started came from Sphinx: https://sphinx-rtd-tutorial.readthedocs.io/en/latest/install.html This tutorial walks you through the installation of sphinx, project setup and configuration, populating documentation, and publishing your docs. From there, we advise copying the simpleble project and editing the files to make your own docs! The simpleble files are fairly simple (!) to understand and act as a great templates for formulating your own project. The reader is also welcome to do something similar with the code used for NeuroDocs (https://github.com/peter3200/NeuroDocs).


Basic Editing Process
*********************

Once you understand the gist of how RTD projects work, go ahead and edit the files to create your own documentation!

1. Start with the /docs/source/index.rst file. This file acts as the table of contents for your project. Add a new page to the toctree list: newpage


2. Create 'newpage':

.. code-block:: console

	$ touch newpage.rst




3. Edit 'newpage': You'll want to add a title in the first line, followed by '=' in the second line (these must be under each character in your title). Subheadings work the same way but with '*' as underlines.



4. Build the new page:

.. code-block:: console

	$ sphinx-build -b html sourcedir builddir



5. Upload your files to Github using the same filestructure on your local drive, or commit your repo



6. If your repo is successfully linked to your RTD account, any changes made in Github will result in automatic updates to your documentation.


