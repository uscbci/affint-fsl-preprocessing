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

export FSLDIR=/usr/local/fsl
source $FSLDIR/etc/fslconf/fsl.sh
export USER=Flywheel
source ~/.bashrc


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

#run script to get input files
${FLYWHEEL_BASE}/get_files.py

#echo Lets look inside $INPUT_DIR
ls $INPUT_DIR


fmriprep_file="${INPUT_DIR}/fmriprep.zip"
if [[ -z $fmriprep_file ]]; then
  echo "$INPUT_DIR has no valid fmriprep files!"
  exit 1
fi
#
# ###UNZIP THE FMRIPREP FILE AND RENAME THE FOLDER
DATA_DIR=$FLYWHEEL_BASE/data
mkdir $DATA_DIR
/usr/bin/unzip $fmriprep_file -d $DATA_DIR
hashed_data_path=`find $DATA_DIR/* -maxdepth 0`
mv $hashed_data_path $DATA_DIR/processed


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



#run confound selection script
${FLYWHEEL_BASE}/confound_selection.py ${subject}
ls ${subject_dir}/ses-KaplanAFFINTAffectiveIntelligence

####################################################################
# FSL PREPROCESSING ANALYSIS
####################################################################
####### Changed RL 6.13.23 #######

affint_tasks=(faceemotion affpics1 affpics2 affpics3 tom emoreg)

for task in ${affint_tasks[@]}; do
  echo "Working on $task for $subject"

  INPUT_DATA=${INPUT_DIR}/${task}_original.nii.gz
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

    cp ${DESIGN_FILE} ${OUTPUT_DIR}/${DESIGN_FILE}

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
