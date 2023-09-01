#!/bin/bash

#Purpose: submit jobs for Kong2022 step 0

#Set paths and vars
HOME=/fslgroup/fslg_spec_networks/compute
CODE_DIR=${HOME}/code/HCP_analysis/Kong2022_parc_fs6/parc_step_0

#Submit a job for each sub/sess
for sub in `cat ${CODE_DIR}/ids.txt`; do
	SUB=${sub}

			#make new matlab and job scripts for each sub/sess
			CODE_DIR2=${CODE_DIR}/subj_scripts/${SUB}
			mkdir -p ${CODE_DIR2}
		
			#matlab script
			matfile=${CODE_DIR}/parc_step_0.m
			cp ${matfile} ${CODE_DIR2}
		
			sed -i 's|SUB|'"${SUB}"'|g' ${CODE_DIR2}/parc_step_0.m

			#job script
			jobfile=${CODE_DIR}/parc_step_0_job.sh
			cp ${jobfile} ${CODE_DIR2}
	
			sed -i 's|${SUB}|'"${SUB}"'|g' ${CODE_DIR2}/parc_step_0_job.sh

			#submit job 
			sbatch ${CODE_DIR2}/parc_step_0_job.sh
	sleep 1
done

