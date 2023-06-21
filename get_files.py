#!/opt/conda/bin/python

import os,sys
import flywheel
import re
import json
import subprocess as sp

# Grab Config
CONFIG_FILE_PATH = '/flywheel/v0/config.json'
with open(CONFIG_FILE_PATH) as config_file:
    config = json.load(config_file)

api_key = config['inputs']['api_key']['key']
session_id = config['destination']['id']

fw = flywheel.Client(api_key)
session = fw.get_session(session_id)

fmriprepfound = False

for analysis in session.analyses:
    if 'fmriprep' in analysis.files[0].gear_info.name:
        for resultfile in analysis.files:
            if "bids-fmriprep" in resultfile.name:
                zip_info = analysis.get_file_zip_info(resultfile)
                print(zip_info)
                fmriprepfound = True
                # print("Downloading fmriprep file %s" % resultfile.name)
                # resultfile.download('input/fmriprep.zip')
            

if not fmriprepfound:
    print("Didn't find the fmriprep file, can't continue")
else:
    for acquisition in session.acquisitions.iter():
        for file in acquisition.files:
            if 'BIDS' in file.info.keys():
                filename = file.info['BIDS']['Filename']
                if "task-faceemotion_run-01" in filename:
                    print("Downloading face emotion...")
                    file.download('input/faceemotion_original.nii.gz')
                    numtrs = int(sp.check_output("fslinfo input/faceemotion_original",shell=True).split()[9])
                    if (numtrs==120):
                        print("Checked 120 TRs correct")
                    else:
                        print("WARNING!!! %d TRs detected" % numtrs)
                if "task-tom_run-01" in filename:
                    print("Downloading tom...")
                    file.download('input/tom_original.nii.gz')
                    numtrs = int(sp.check_output("fslinfo input/tom_original",shell=True).split()[9])
                    if (numtrs==234):
                        print("Checked 234 TRs correct")
                    else:
                        print("WARNING!!! %d TRs detected" % numtrs)
                if "task-emoreg_run-01" in filename:
                    print("Downloading emoreg...")
                    file.download('input/emoreg_original.nii.gz')
                    numtrs = int(sp.check_output("fslinfo input/emoreg_original",shell=True).split()[9])
                    if (numtrs==285):
                        print("Checked 285 TRs correct")
                    else:
                        print("WARNING!!! %d TRs detected" % numtrs)
                if "task-affectivepictures_run-01" in filename:
                    print("Downloading pics run 1...")
                    file.download("input/affpics1_original.nii.gz")
                    numtrs = int(sp.check_output("fslinfo input/affpics1_original",shell=True).split()[9])
                    if (numtrs==186):
                        print("Checked 186 TRs correct")
                    else:
                        print("WARNING!!! %d TRs detected" % numtrs)
                if "task-affectivepictures_run-02" in filename:
                    print("Downloading pics run 2...")
                    file.download("input/affpics2_original.nii.gz")
                    numtrs = int(sp.check_output("fslinfo input/affpics2_original",shell=True).split()[9])
                    if (numtrs==186):
                        print("Checked 186 TRs correct")
                    else:
                        print("WARNING!!! %d TRs detected" % numtrs)
                if "task-affectivepictures_run-03" in filename:
                    print("Downloading pics run 3...")
                    file.download("input/affpics3_original.nii.gz")
                    numtrs = int(sp.check_output("fslinfo input/affpics3_original",shell=True).split()[9])
                    if (numtrs==186):
                        print("Checked 186 TRs correct")
                    else:
                        print("WARNING!!! %d TRs detected" % numtrs)
                
                

