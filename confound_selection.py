#!/usr/bin/env python

import os
import shutil
import csv
import pandas as pd
import sys
from subprocess import call

#command line options
if (len(sys.argv) < 2):
	print("\n\tusage: %s <subject>\n" % sys.argv[0])
	sys.exit()
else:
	subject = sys.argv[1]

print("Working on confounds for subject %s" % subject)

FLYWHEEL_BASE="/flywheel/v0"
OUTPUT_DIR="%s/output" % FLYWHEEL_BASE
INPUT_DIR="%s/input" % FLYWHEEL_BASE
DATA_DIR="%s/data" % FLYWHEEL_BASE #this should be where fmriprep unzips to

og_task_names = ["affectivepictures_run-1", "affectivepictures_run-2", "affectivepictures_run-3", "emotionregulation_run-1", "faceemotion_run-1", "tom_run-1"]
new_task_names = ["affpics1", "affpics2", "affpics3", "emoreg", "faceemotion", "tom"]

for i in range(len(og_task_names)):
	og_name = og_task_names[i]
	new_name = new_task_names[i]
	print("Working on task %s" % og_name)

	conf_file = "%s/fmriprep/sub-%s/ses-KaplanAFFINTAffectiveIntelligence/func/sub-%s_ses-KaplanAFFINTAffectiveIntelligence_task-%s_desc-confounds_timeseries.tsv" % (DATA_DIR, subject, subject, og_name)

	confs = pd.read_csv(conf_file,sep='\t')

	target_cols = ["a_comp_cor_00", "trans_x", "trans_y", "trans_z", "rot_x", "rot_y", "rot_z"]

	newdf = confs.loc[:, confs.columns.isin(target_cols) | confs.columns.str.contains('motion') | confs.columns.str.contains('aroma')]

	final_file = "%s/fmriprep/sub-%s/ses-KaplanAFFINTAffectiveIntelligence/sub-%s_confounds_%s.tsv" % (DATA_DIR, subject, subject, new_name)

	newdf.to_csv(final_file,sep="\t")


print("Done with confound creation for %s" % subject)
print('\n')
