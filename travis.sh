#!/bin/bash

usage() {
    echo "<program> -r username/repo -s <start_build> -e <end_build> -o <output_file.png> [-cached] [-version]"
    exit 1;
}
version="1.0";

while getopts ":c:r:s:e:o:v:" opt; do
  case ${opt} in
    c)
      cached="true"
      ;;
    r)
      repo=${OPTARG}
      ;;
    s)
      sbuild=${OPTARG}
      ;;
    e)
      ebuild=${OPTARG}
      ;;
    o)
      outfile=${OPTARG}
      ;;
    v)
      echo Version $version
      exit 1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2 
      exit 1
      ;;
  esac
done
echo ${sbuild}
echo ${ebuild}
echo ${outfile}
echo ${cached}
echo ${repo}
if [ -z "${sbuild}" ] || [ -z "${ebuild}" ] || [ -z "${outfile}" ]  || [ -z "${repo}" ]; then
    usage
    exit 1
fi


for i in `seq $sbuild 25 $ebuild`; do
    echo Processing build $i $1;
    if [[ ! -f $i.parsed.json || $cached -eq "true" ]]; then
        travis raw --json /repos/$repo/builds?after_number=$i | \
            Rscript regularize_json.R > $i.parsed.json;
    fi
done;

Rscript merge_json.R *parsed.json > out.json;
cat out.json | Rscript process.R $outfile
