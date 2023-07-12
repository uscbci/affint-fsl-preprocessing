#!/opt/conda/bin/python

import sys
import os
from subprocess import call

subject = sys.argv[1]

pathbase = "/flywheel/v0/input"
nonlinear_xform = "%s/sub-%s_ses-KaplanAFFINTAffectiveIntelligence_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5" % (pathbase,subject)
tasks = ["affectivepictures_run-1","affectivepictures_run-2","affectivepictures_run-3","emotionregulation_run-1","faceemotion_run-1","tom_run-1"]
task_names = ["affpics1", "affpics2","affpics3","emoreg","faceemotion", "tom"]

task_num = 0

for task in tasks:

    task_name = task_names[task_num]
    input_image = "/flywheel/v0/output/%s_preprocessed_%s.feat/stats/res4d_high.nii.gz" % (subject,task_name)
    output_image = "/flywheel/v0/output/%s_%s_cleaned_standard.nii.gz" % (subject,task_name)

    scanner2T1xform = "%s/sub-%s_ses-KaplanAFFINTAffectiveIntelligence_task-%s_from-scanner_to-T1w_mode-image_xfm.txt" % (pathbase,subject,task)

    command = "antsApplyTransforms --dimensionality 3 --input-image-type 3 -i %s -r /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz -t %s -t %s -o %s" % (input_image,scanner2T1xform,nonlinear_xform,output_image)
    
    print(command)
    call(command,shell=True)

    task_num +=1
