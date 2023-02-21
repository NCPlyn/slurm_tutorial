#!/bin/bash
#
#SBATCH --job-name=test
#SBATCH --output=res.txt
#SBATCH --partition=debug
#
#SBATCH --time=1:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=200

echo "scale=4000; 4*a(1)" | bc -l
