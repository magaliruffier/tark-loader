#!/bin/bash

# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



# A POSIX variable
# OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
ENSDIR=""
BATCH_COUNT=1000
SPECIES="homo_sapiens"
ASSEMBLY=38
RELEASE_EG_FROM=0
RELEASE_FROM=76
RELEASE_TO=${RELEASE_FROM}
PREVIOUS_RELEASE=${RELEASE_FROM}
NAMING_CONSORTIUM="HGNC"
ADD_CONSORTIUM_NAME=1
TARK_DB="test_tark"
EXCLUDE_SOURCE=""
INCLUDE_SOURCE=""
SOURCE_NAME="Ensembl"
verbose=0

HELP="\n\t-h Displays this message\n\t-a ASSEMBLY (default ${ASSEMBLY})\n\t-b BATCH_COUNT\n\t-c NAING_CONSORTIUM\n\t-d ENSDIR\n\t-e EXCLUDE_SOURCE\n\t-i INCLUDE_SOURCE\n\t-m RELEASE_EG_FROM\n\t-n ADD_CONSORTIUM_NAME\n\t-p PREVIOUS_RELEASE (default ${PREVIOUS_RELEASE})\n\t-q RELEASE_FROM (default: ${RELEASE_FROM})\n\t-r RELEASE_TO (default: ${RELEASE_TO})\n\t-s SPECIES (default: ${SPECIES})\n\t-t TARK_DB (default $TARK_DB)\n\t-w SOURCE_NAME (default: ${SOURCE_NAME})"

while getopts "h?:a:b:c:d:e:i:m:n:p:q:r:s:t:w:" opt; do
    case "${opt}" in
    h|\?)
        echo "Loader for importing ensembl core dbs into the Tark db."
        echo -e $HELP
        echo -e "\n- Separate loads should be done for each assembly change."
        echo "- Database parameters are defined using the helper scripts within this wrapper. This uses the public archive as the source of cores, the dev tark server for the loading and the hive server for the related hive dbs."
        exit 0
        ;;
    a)  ASSEMBLY=$OPTARG
        ;;
    b)  BATCH_COUNT=$OPTARG
        ;;
    c)  NAMING_CONSORTIUM=$OPTARG
        ;;
    d)  ENSDIR=$OPTARG
        ;;
    e)  EXCLUDE_SOURCE=$OPTARG
        ;;
    i)  INCLUDE_SOURCE=$OPTARG
        ;;
    m)  RELEASE_EG_FROM=$OPTARG
        ;;
    n)  ADD_CONSORTIUM_NAME=$OPTARG
        ;;
    q)  RELEASE_FROM=$OPTARG
        ;;
    r)  RELEASE_TO=$OPTARG
        ;;
    p)  PREVIOUS_RELEASE=$OPTARG
        ;;
    s)  SPECIES=$OPTARG
        ;;
    t)  TARK_DB=$OPTARG
        ;;
    w)  SOURCE_NAME=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

if [ $TARK_DB = "test_tark" ]
then
  echo "Please define a Tark db"
  echo -e $HELP
  echo -e "\n- Separate loads should be done for each assembly change."
  echo "- Database parameters are defined using the helper scripts within this wrapper. This uses the public archive as the source of cores, the dev tark server for the loading and the hive server for the related hive dbs."
  exit 0
fi

if [ $RELEASE_TO = 0 ]
then
  RELEASE_TO=$RELEASE_FROM
fi

if [ $PREVIOUS_RELEASE = 0 ]
then
  PREVIOUS_RELEASE=$RELEASE_FROM
fi

ESOURCE=${#EXCLUDE_SOURCE}
ISOURCE=${#INCLUDE_SOURCE}
if [ "$ESOURCE" -gt "0" ] && [ "$ISOURCE" -gt "0" ]
then
  echo "Please specify only -e OR -i."
fi

TAG_DESCRITPION="Ensembl release"
if [ "$ISOURCE" -gt "0" ]
then
  TAG_DESCRITPION="Ensembl release (${SOURCE_NAME})"
fi

eval $(mysql-ens-tark-dev-1-ensrw details env_TARK_)
eval $(mysql-ens-hive-prod-2-ensrw details env_HIVE_)

CORE_HOST=ensembldb.ensembl.org
CORE_PORT=3306
CORE_USER=anonymous

NAMING_CONSORTIUM_PARAM=""
if [ ${#NAMING_CONSORTIUM} -gt 0 ]
then
  NAMING_CONSORTIUM_PARAM=" --naming_consortium ${NAMING_CONSORTIUM}"
fi

ADD_CONSORTIUM_NAME_PARAM=""
if [ $ADD_CONSORTIUM_NAME == 1 ]
then
  ADD_CONSORTIUM_NAME_PARAM=" --add_consortium_prefix 1"
fi

for RELEASE in $( seq $RELEASE_FROM $RELEASE_TO)
do

  CORE_DB=${SPECIES}_core_${RELEASE}_${ASSEMBLY}
  if [ $RELEASE_EG_FROM -gt 0 ]
  then
    CORE_DB=${SPECIES}_core_${RELEASE_EG_FROM}_${RELEASE}_${ASSEMBLY}
  fi

  HIVE_DB_NAME=hive_${TARK_DB}_${RELEASE}
  HIVE_DB=${USER}_${HIVE_DB_NAME}

  echo "Loading ${SPECIES}_core_${RELEASE}_${ASSEMBLY}, PREVIOUS_RELEASE was ${PREVIOUS_RELEASE}"

  perl -Ilocal/lib/perl5 ${ENSDIR}/ensembl-hive/scripts/init_pipeline.pl \
    Bio::EnsEMBL::Tark::Hive::PipeConfig::TarkLoader_conf                \
    --tark_host ${TARK_HOST} --tark_port ${TARK_PORT} --tark_user ${TARK_USER} --tark_pass ${TARK_PASS} \
    --tark_db ${TARK_DB} --core_host ${CORE_HOST} --core_port ${CORE_PORT} \
    --core_user ${CORE_USER} --core_pass '' --core_dbname ${CORE_DB} \
    --host ${HIVE_HOST} --port ${HIVE_PORT} --user ${HIVE_USER} --password ${HIVE_PASS} \
    --pipeline_name ${HIVE_DB_NAME} --species ${SPECIES} \
    --tag_block release --tag_shortname ${RELEASE} --tag_description "$TAG_DESCRITPION" \
    --tag_feature_type all --tag_version 1 \
    --block_size ${BATCH_COUNT} --report ${PWD}/loading_report_${RELEASE}.json \
    --tag_previous_shortname ${PREVIOUS_RELEASE} --source_name ${SOURCE_NAME} \
    --exclude_source "$EXCLUDE_SOURCE" --include_source "$INCLUDE_SOURCE" \
    ${NAMING_CONSORTIUM_PARAM} ${ADD_CONSORTIUM_NAME_PARAM}

  perl -Ilocal/lib/perl5 ${ENSDIR}/ensembl-hive/scripts/beekeeper.pl -url mysql://${HIVE_USER}:${HIVE_PASS}@${HIVE_HOST}:${HIVE_PORT}/${HIVE_DB} -loop
  
  #echo "Updating 5' and 3' UTR checksum in translation table after loading ${CORE_DB} ..."
  #mysql -h${TARK_HOST} -P${TARK_PORT} -u${TARK_USER} -p${TARK_PASS} ${TARK_DB} -e "UPDATE translation tl INNER JOIN translation_transcript tt ON tt.translation_id = tl.translation_id INNER JOIN (SELECT max(transcript_id) as transcript_id FROM transcript GROUP BY stable_id,assembly_id) AS v0 ON v0.transcript_id = tt.transcript_id INNER JOIN transcript t ON tt.transcript_id = t.transcript_id INNER JOIN sequence s ON s.seq_checksum = t.seq_checksum  SET tl.five_utr_checksum = UNHEX(SHA1(IF(t.loc_strand = 1 AND tl.loc_strand = 1, SUBSTRING(s.sequence,1,tl.loc_start-t.loc_start), SUBSTRING(s.sequence,1,t.loc_end-tl.loc_end)))), tl.three_utr_checksum = UNHEX(SHA1(IF(t.loc_strand = 1 AND tl.loc_strand = 1, SUBSTRING(s.sequence,-(t.loc_end-tl.loc_end)), SUBSTRING(s.sequence,-(tl.loc_start-t.loc_start)))));"
  
  echo "Optimizing Tark tables after loading ${CORE_DB} ..."
  mysql -h${TARK_HOST} -P${TARK_PORT} -u${TARK_USER} -p${TARK_PASS} ${TARK_DB} -N -e "show tables;" | while read table; do echo "Optimizing $table ...     "; mysql -h${TARK_HOST} -P${TARK_PORT} -u${TARK_USER} -p${TARK_PASS} ${TARK_DB} -e "optimize table $table;"; done

  PREVIOUS_RELEASE=${RELEASE}
  if [ $RELEASE_EG_FROM -gt 0 ]
  then
    RELEASE_EG_FROM=${RELEASE_EG_FROM}+1
  fi

done

