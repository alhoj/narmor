#!/bin/sh

chmod 755 /m/nbe/scratch/narmor/scripts/jobs/*

# This is the part where we submit the jobs that we cooked

for j in $(ls -1 "/m/nbe/scratch/narmor/scripts/jobs/");do
sbatch "/m/nbe/scratch/narmor/scripts/jobs/"$j
done
echo "All jobs submitted!"

#rm slurm-*
