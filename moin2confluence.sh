#!/bin/bash

# change to directory where script is located
CUR=$(dirname "$0")
WORKING=$CUR/working

PAGENAME=$1
MOINROOT=$2
OUTPUT=$3

if [[ "$OUTPUT" == ""  ]]; then
	echo ""
	echo "Syntax: ./$0 <PageName> <wiki root> <output dir>"
	echo "Example: ./$0 Certificates /data/webs/DVTech outputdir"
	echo "The wiki root directory should be the one that contains the data directory"
	echo ""
	exit 1;
fi

mkdir -p $WORKING
mkdir -p $OUTPUT

LATEST_REV=`ls $MOINROOT/data/pages/$PAGENAME/revisions | sort -r | head -n 1`
cp $MOINROOT/data/pages/$PAGENAME/revisions/$LATEST_REV $WORKING/$PAGENAME.wiki

# convert moinmoin to mediawiki
# the moinmoin format is very similar to mediawiki
# here we convert a few things that are different
sed -i "s/^ \*/*/g" "$WORKING/$PAGENAME.wiki"
sed -i "s/^ 1. /# /g" "$WORKING/$PAGENAME.wiki"
sed -i "s/^  1. /## /g" "$WORKING/$PAGENAME.wiki"
sed -i "s/{{{/<pre>/g" "$WORKING/$PAGENAME.wiki"
sed -i "s/}}}/<\/pre>/g" "$WORKING/$PAGENAME.wiki"

# convert from mediawiki to markdown
pandoc -f mediawiki -t markdown -s "$WORKING/$PAGENAME.wiki" -o "$WORKING/$PAGENAME.md"

# Here we clean up the file names and replace common special characters used
CLEANFILE=$PAGENAME

# apos
CLEANFILE=`echo $CLEANFILE | sed "s/(27)/'/g"`

# space
CLEANFILE=`echo $CLEANFILE | sed "s/(20)/ /g"`

# For subpages / is used, we replace / with __
# /
CLEANFILE=`echo $CLEANFILE | sed "s/(2f)/__/g"`

# -
CLEANFILE=`echo $CLEANFILE | sed "s/(2d)/'/g"`

# converts markdown to confluence
pandoc "$WORKING/$PAGENAME.md" -t confluence.lua > "$OUTPUT/$CLEANFILE"

# Here we replace the subpage links with Page__ChildPage so that the links still work

# convert subpage link 1
sed -i "s/href='\/\(.*\)'/href='${CLEANFILE}__\1'/g" "$OUTPUT/$CLEANFILE"

# convert subpage link 2
sed -i "s/href='${CLEANFILE}\/\(.*\)'/href='${CLEANFILE}__\1'/g" "$OUTPUT/$CLEANFILE"


