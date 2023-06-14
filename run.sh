#! /bin/bash
#
#


###############################################################################
# Built to flywheel-v0 spec.

CONTAINER=affint-feat
echo -e "$CONTAINER  Initiated"

FLYWHEEL_BASE=/flywheel/v0
OUTPUT_DIR=$FLYWHEEL_BASE/output
INPUT_DIR=$FLYWHEEL_BASE/input
MANIFEST=$FLYWHEEL_BASE/manifest.json
CONFIG_FILE=$FLYWHEEL_BASE/config.json

#Colors
RED='\033[0;31m'
NC='\033[0m'

###############################################################################
# Configure the ENV

export FSLDIR=/opt/fsl-6.0.1
source $FSLDIR/etc/fslconf/fsl.sh
export USER=Flywheel
pip install pandas


##############################################################################
# Parse configuration

function parse_config {

  CONFIG_FILE=$FLYWHEEL_BASE/config.json
  MANIFEST_FILE=$FLYWHEEL_BASE/manifest.json

  if [[ -f $CONFIG_FILE ]]; then
    echo "$(cat $CONFIG_FILE | jq -r '.config.'$1)"
  else
    CONFIG_FILE=$MANIFEST_FILE
    echo "$(cat $MANIFEST_FILE | jq -r '.config.'$1'.default')"
  fi
}

###############################################################################
##################### CHANGING FROM HERE RL 6.12.23 #####################
# INPUT Files

#echo Lets look inside $INPUT_DIR
ls $INPUT_DIR


fmriprep_file=`find $INPUT_DIR/fmriprep/* -maxdepth 0 -not -path '*/\.*' -type f -name "*.zip" | head -1`
if [[ -z $fmriprep_file ]]; then
  echo "$INPUT_DIR has no valid fmriprep files!"
  exit 1
fi
#
# ###UNZIP THE FMRIPREP FILE AND RENAME THE FOLDER
DATA_DIR=$FLYWHEEL_BASE/data
mkdir $DATA_DIR
unzip $fmriprep_file -d $DATA_DIR
hashed_data_path=`find $DATA_DIR/* -maxdepth 0`
mv $hashed_data_path $DATA_DIR/processed



# Looking for the individual nifti files
# Face emotion
faceemo_file=`find $INPUT_DIR/faceemotion/* -maxdepth 0 -not -path '*/\.*' -type f -name "*.nii.gz" | head -1`
if [[ -z $faceemo_file ]]; then
  echo "$INPUT_DIR has no valid face emotion file!"
  exit 1
fi

mkdir ${DATA_DIR}/niftis
mv $faceemo_file ${DATA_DIR}/niftis #this is the original script
mv $faceemo_file ${DATA_DIR}/niftis/faceemotion_og.nii.gz #maybe could use this to name the files more specifically??
echo "Listing Niftis... Do we see Face Emotion?"
ls $DATA_DIR/niftis


# Affective pictures; run 1
aff1_file=`find $INPUT_DIR/affpics1/* -maxdepth 0 -not -path '*/\.*' -type f -name "*.nii.gz" | head -1`
if [[ -z $aff1_file ]]; then
  echo "$INPUT_DIR has no valid affective pics run 1 file!"
  exit 1
fi

mv $aff1_file ${DATA_DIR}/niftis
echo "Listing Niftis... Do we see AffectivePics Run 1?"
ls $DATA_DIR/niftis


# Affective pictures; run 2
aff2_file=`find $INPUT_DIR/affpics2/* -maxdepth 0 -not -path '*/\.*' -type f -name "*.nii.gz" | head -1`
if [[ -z $aff2_file ]]; then
  echo "$INPUT_DIR has no valid affective pics run 2 file!"
  exit 1
fi

mv $aff2_file ${DATA_DIR}/niftis
echo "Listing Niftis... Do we see AffectivePics Run 2?"
ls $DATA_DIR/niftis


# Affective pictures; run 3
aff3_file=`find $INPUT_DIR/affpics3/* -maxdepth 0 -not -path '*/\.*' -type f -name "*.nii.gz" | head -1`
if [[ -z $aff3_file ]]; then
  echo "$INPUT_DIR has no valid affective pics run 3 file!"
  exit 1
fi

mv $aff3_file ${DATA_DIR}/niftis
echo "Listing Niftis... Do we see AffectivePics Run 3?"
ls $DATA_DIR/niftis


# Theory of mind
tom_file=`find $INPUT_DIR/tom/* -maxdepth 0 -not -path '*/\.*' -type f -name "*.nii.gz" | head -1`
if [[ -z $tom_file ]]; then
  echo "$INPUT_DIR has no valid theory of mind file!"
  exit 1
fi

mv $tom_file ${DATA_DIR}/niftis
echo "Listing Niftis... Do we see Theory of Mind?"
ls $DATA_DIR/niftis


# Emotion Regulation
emoreg_file=`find $INPUT_DIR/emoreg/* -maxdepth 0 -not -path '*/\.*' -type f -name "*.nii.gz" | head -1`
if [[ -z $emoreg_file ]]; then
  echo "$INPUT_DIR has no valid emotion regulation file!"
  exit 1
fi

mv $emoreg_file ${DATA_DIR}/niftis
echo "Listing Niftis... Do we see Emotion Regulation?"
ls $DATA_DIR/niftis




# ##FIND AND UNZIP STIM REORDER CSV
# reorder_file=`find $INPUT_DIR/reorderfile/* -maxdepth 0 -not -path '*/\.*' -type f -name "*.zip" | head -1`
#
# if [[ -z $reorder_file ]]; then
#   echo "$INPUT_DIR has no valid reorder file!"
#   exit 1
# fi
#
# mkdir ${DATA_DIR}/reorder
# unzip $reorder_file -d $DATA_DIR/reorder
# ls $DATA_DIR
# echo "LISTING REORDER FILE:"
# ls $DATA_DIR/reorder


echo "LISTING FILES IN FLYWHEEL_BASE:"
ls ${FLYWHEEL_BASE}
echo ""
echo ""


##GET SUBJECT ID
subfolder=`find $DATA_DIR/processed/fmriprep/sub-* -maxdepth 0 | head -1`
echo "Testing length of $subfolder: ${#subfolder}"
if [[ ${#subfolder} > 45 ]]
then
  echo "3digit subject number detected"
  subject=${subfolder: -5}
else
  echo "2digit subject number detected"
  subject=${subfolder: -4}
fi

subject_dir=$DATA_DIR/processed/fmriprep/sub-$subject

##DEFINE INPUT FILES
# func_affectivepictures_r1=$subject_dir/ses-KaplanAFFINTAffectiveIntelligence/func/sub-${subject}_ses-KaplanAFFINTAffectiveIntelligence_task-affectivepictures_run-1_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
# func_affectivepictures_r2=$subject_dir/ses-KaplanAFFINTAffectiveIntelligence/func/sub-${subject}_ses-KaplanAFFINTAffectiveIntelligence_task-affectivepictures_run-2_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
# func_affectivepictures_r3=$subject_dir/ses-KaplanAFFINTAffectiveIntelligence/func/sub-${subject}_ses-KaplanAFFINTAffectiveIntelligence_task-affectivepictures_run-3_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
#
# if test -f $func_affectivepictures_r1; then
# 	echo Found AffectivePictures run 1 file: $func_affectivepictures_r1
# else
# 	echo Could not find $func_affectivepictures_r1
# fi
# if test -f $func_affectivepictures_r2; then
# 	echo Found AffectivePictures run 2 file: $func_affectivepictures_r2
# else
# 	echo Could not find $func_affectivepictures_r2
# fi
# if test -f $func_affectivepictures_r3; then
# 	echo Found AffectivePictures run 3 file: $func_affectivepictures_r3
# else
# 	echo Could not find $func_affectivepictures_r3
# fi



####################################################################
# FSL PREPROCESSING ANALYSIS
####################################################################
####### Changed RL 6.13.23 #######

affint_tasks=(faceemotion affpics1 affpics2 affpics3 tom emoreg)

for task in ${affint_tasks[@]}; do
  echo "Working on $task for $subject"

  INPUT_DATA=${DATA_DIR}/niftis/${task}_og.nii.gz
  if [[ -z $INPUT_DATA ]]; then
    echo "$INPUT_DIR has no valid ${task} file!"
  else
    FEAT_OUTPUT_DIR=${OUTPUT_DIR}/${subject}_preprocessed_${task}.feat
    CONFOUND_CSV=${subject_dir}/ses-KaplanAFFINTAffectiveIntelligence/sub-${subject}_confounds_${task}.tsv


    TEMPLATE=$FLYWHEEL_BASE/preproc_template.fsf
  	DESIGN_FILE=${OUTPUT_DIR}/preproc_${task}.fsf
  	cp ${TEMPLATE} ${DESIGN_FILE}

    #Check number of timepoints in data
    NUMTIMEPOINTS=`fslinfo ${INPUT_DATA} | grep ^dim4 | awk {'print $2'}`



    VAR_STRINGS=( INPUT_DATA FEAT_OUTPUT_DIR CONFOUND_CSV NUMTIMEPOINTS)

    # loop through and preform substitution
  	for var_name in ${VAR_STRINGS[@]}; do

  	  var_val=` eval 'echo $'$var_name `

  	  echo will substitute $var_val for $var_name in design file
  	  #We need to replace and backslashes with "\/"
  	  var_val=` echo ${var_val////"\/"} `

  	  sed -i -e "s/\^${var_name}\^/${var_val}/g" ${DESIGN_FILE}
  	  echo sed -i -e "s/\^${var_name}\^/${var_val}/g" ${DESIGN_FILE}

  	done

  	# RUN THE Algorithm with the .FSF FILE
  	ls $INPUT_DATA


    echo Starting FEAT Preprocessing for Task ${task}...
  	time feat ${DESIGN_FILE}
  	FEAT_EXIT_STATUS=$?

  	if [[ $FEAT_EXIT_STATUS == 0 ]]; then
  	  echo -e "FEAT completed successfully!"
  	fi

  	echo What have we got now
  	ls ${OUTPUT_DIR}

    # Upon success, convert index to a webpage
  	if [[ $FEAT_EXIT_STATUS == 0 ]]; then
  	  # Convert index to standalone index
  	  echo "$CONTAINER  generating output html..."
  	  output_html_files=$(find ${FEAT_OUTPUT_DIR} -type f -name "report_poststats.html")
  	  for f in $output_html_files; do
  	    web2htmloutput=${OUTPUT_DIR}/${subject}_affpics_run${RUN}_`basename $f`
  	    python /opt/webpage2html/webpage2html.py -q -s "$f" > "$web2htmloutput"
  	  done
  	fi

  fi

done



for task in ${affint_tasks[@]}
do
  FEAT_OUTPUT_DIR=${OUTPUT_DIR}/${subject}_preprocessed_${task}.feat
  if [[ -z $FEAT_OUTPUT_DIR ]]; then
    echo "$FEAT_OUTPUT_DIR does not exist!"
  else
    echo feat directory is ${FEAT_OUTPUT_DIR}

    if [[ $FEAT_EXIT_STATUS == 0 ]]; then

      echo -e "${CONTAINER}  Compressing outputs..."

      # Zip and move the relevant files to the output directory
      zip -rq ${OUTPUT_DIR}/${subject}_preprocessed_${task}.zip ${FEAT_OUTPUT_DIR}
      rm -rf ${FEAT_OUTPUT_DIR}

    fi
  fi
done

echo Lets see what we have after zipping etc
ls ${OUTPUT_DIR}


####################################################################
# AFFECTIVEPICTURES ANALYSIS - OG
####################################################################

# TEMPLATE=affectivepictures_template.fsf
#
# for RUN in {1..3}
# do
# 	echo -e "\n\n${CONTAINER} Beginning analysis for affective pictures run ${RUN}"
#
# 	INPUT_DATA=`eval 'echo $'func_affectivepictures_r${RUN} `
# 	FEAT_OUTPUT_DIR=${OUTPUT_DIR}/${subject}_affectivepictures_run${RUN}.feat
# 	NEUTRAL1_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Neutral1.txt
#   NEUTRAL2_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Neutral2.txt
#   NEUTRAL3_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Neutral3.txt
# 	FEAR1_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Fear1.txt
#   FEAR2_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Fear2.txt
#   FEAR3_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Fear3.txt
# 	HAPPY1_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Happy1.txt
#   HAPPY2_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Happy2.txt
#   HAPPY3_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Happy3.txt
# 	SAD1_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Sad1.txt
#   SAD2_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Sad2.txt
#   SAD3_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Sad3.txt
# 	DISGUST1_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Disgust1.txt
#   DISGUST2_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Disgust2.txt
#   DISGUST3_EV=${DATA_DIR}/logs/${subject}_affectivepictures_run${RUN}_Disgust3.txt
#
#
# 	TEMPLATE=$FLYWHEEL_BASE/affectivepictures_template.fsf
# 	DESIGN_FILE=${OUTPUT_DIR}/affectivepictures_run${RUN}.fsf
# 	cp ${TEMPLATE} ${DESIGN_FILE}
#
#   #Check number of timepoints in data
#   NUMTIMEPOINTS=`fslinfo ${INPUT_DATA} | grep ^dim4 | awk {'print $2'}`
#
#   #Should be 120 for these runs
#   if [ $NUMTIMEPOINTS -eq 186 ]; then
#     echo "Number of timepoints is correct at ${NUMTIMEPOINTS}"
#   else
#     echo -e "${RED}WARNING!!! Number of timepoints should be 186 but is ${NUMTIMEPOINTS} ${NC}"
#   fi
#
#   VAR_STRINGS=( INPUT_DATA FEAT_OUTPUT_DIR NEUTRAL1_EV NEUTRAL2_EV NEUTRAL3_EV FEAR1_EV FEAR2_EV FEAR3_EV HAPPY1_EV HAPPY2_EV HAPPY3_EV SAD1_EV SAD2_EV SAD3_EV DISGUST1_EV DISGUST2_EV DISGUST3_EV NUMTIMEPOINTS)
#
#
# 	# loop through and preform substitution
# 	for var_name in ${VAR_STRINGS[@]}; do
#
# 	  var_val=` eval 'echo $'$var_name `
#
# 	  echo will substitute $var_val for $var_name in design file
# 	  #We need to replace and backslashes with "\/"
# 	  var_val=` echo ${var_val////"\/"} `
#
# 	  sed -i -e "s/\^${var_name}\^/${var_val}/g" ${DESIGN_FILE}
# 	  echo sed -i -e "s/\^${var_name}\^/${var_val}/g" ${DESIGN_FILE}
#
# 	done
#
# 	# RUN THE Algorithm with the .FSF FILE
# 	ls $INPUT_DATA
#
# 	echo Starting FEAT for Affective Pictures run ${RUN}...
# 	time feat ${DESIGN_FILE}
# 	FEAT_EXIT_STATUS=$?
#
# 	if [[ $FEAT_EXIT_STATUS == 0 ]]; then
# 	  echo -e "FEAT completed successfully!"
# 	fi
#
# 	echo What have we got now
# 	ls ${OUTPUT_DIR}
#
#   #add a fake reg folder
#   ${FLYWHEEL_BASE}/make_reg_folder.py ${FEAT_OUTPUT_DIR}
#
# 	# Upon success, convert index to a webpage
# 	if [[ $FEAT_EXIT_STATUS == 0 ]]; then
# 	  # Convert index to standalone index
# 	  echo "$CONTAINER  generating output html..."
# 	  output_html_files=$(find ${FEAT_OUTPUT_DIR} -type f -name "report_poststats.html")
# 	  for f in $output_html_files; do
# 	    web2htmloutput=${OUTPUT_DIR}/${subject}_affpics_run${RUN}_`basename $f`
# 	    python /opt/webpage2html/webpage2html.py -q -s "$f" > "$web2htmloutput"
# 	  done
# 	fi
#
#
#
# done








#NOW WE CAN ZIP THE FEAT FOLDERS
# CLEANUP THE OUTPUT DIRECTORIES

# for RUN in {1..3}
# do
#   FEAT_OUTPUT_DIR=${OUTPUT_DIR}/${subject}_affectivepictures_run${RUN}.feat
#   echo feat directory is ${FEAT_OUTPUT_DIR}
#
#   if [[ $FEAT_EXIT_STATUS == 0 ]]; then
#
#     echo -e "${CONTAINER}  Compressing outputs..."
#
#     # Zip and move the relevant files to the output directory
#     zip -rq ${OUTPUT_DIR}/${subject}_affectivepictures_run${RUN}.zip ${FEAT_OUTPUT_DIR}
#     rm -rf ${FEAT_OUTPUT_DIR}
#
#   fi
# done
# echo Lets see what we have after zipping etc
# ls ${OUTPUT_DIR}
