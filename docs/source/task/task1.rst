Task Analysis Step 1: Timing Files
==================================

What are timing files?
**********************

Timing files are simple text files that contain the start time of a task trial, the duration of that trial, and the task contrast. 

For example, let's use a language localizer task. For this task, participants read sentences with words and strings of nonwords. So, our trial onset times will be whenever the sentences or nonwords are shown on the screen, the trial durations are the length of time the sentence or nonwords blocks are shown, and the task contrast label will indicate if it is a sentence or nonwords trial.  

Creating timing files
*********************

It is best to design your experiment with your first-level model in mind (and hence the timing files, which contribute to the formulation of that design). However, if you are using data that has been previously collected, it can be a little tricky to know where to start with these. However, this can be simplified into three basic steps:

1. Calculate trial onset times
2. Calculate trial durations
3. Label each trial with its particular task contrast label 

We will create these timing files for two different tasks using two different approaches: MATLAB and Python


MATLAB timing files
******************************

1. Load MATLAB, claim an `salloc` job, and launch MATLAB

.. code-block:: console
	
    $ ml matlab/r2018b
    $ salloc --mem-per-cpu 15G --time 24:00:00 --x11
    $ LD_PRELOAD= matlab

2. In MATLAB, view our example .mat task output file. 
