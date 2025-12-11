# Write-up 0: template

**Name:** Owen Dunkley  
**Student ID:** odunkley  
**Date:** 11/11/2025  

---

## Overview

Notes taken during the first presentation and day 1

---

## Content

Finished setting up my directory for HW1, then sent to Setup/Setup.md and followed steps as indicated
> added an alias to ~/bashrc (alias qu='squeue -u $USER')
> installed micromamba
> made a docker account etc.
> added a GCP account
> installed nextflow onto farmshare
> skipped on setting up the ML accounts just yet, but I'll get back to that later

**SLURM EXERCISE**
> How many slurm jobs will be submitted?
3 (#SBATCH --array=0-2 submits a job for 0, 1, and 2)
> What is the purpose of the if statement?
Interesting choice - I was not familiar with this modulus-based job dispatching loop before, but taking the mod of the 3 array jobs (i % SLURM_ARRAY_TASK_COUNT) dispatches the jop associated with a given line in the input datafile to one of the three arrayed jobs based on whether the remainder is 0, 1, or 2, splitting the dispatching of input lines evenly between the three jobs.
> What is the expected output in each *.out file 
Each outfile whould have only the lines corresponding to the lines in the datafile for which the mod of i == the array job's index, printing to the file each "$i: $value" pair as a new line.

