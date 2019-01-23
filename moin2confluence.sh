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

# handle 8 column tables
sed -i "s/^||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><td>\4<\/td><td>\5<\/td><td>\6<\/td><td>\7<\/td><td>\8<\/td><\/tr>/g" "$WORKING/$PAGENAME.wiki"

# handle 7 column tables
sed -i "s/^||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><td>\4<\/td><td>\5<\/td><td>\6<\/td><td>\7<\/td><\/tr>/g" "$WORKING/$PAGENAME.wiki"

# handle 6 column tables
sed -i "s/^||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><td>\4<\/td><td>\5<\/td><td>\6<\/td><\/tr>/g" "$WORKING/$PAGENAME.wiki"

# handle 5 column tables
sed -i "s/^||\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)||/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><td>\4<\/td><td>\5<\/td><\/tr>/g" "$WORKING/$PAGENAME.wiki"

# handle 4 column tables
sed -i "s/^||\(.*\)||\(.*\)||\(.*\)||\(.*\)||/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><td>\4<\/td><\/tr>/g" "$WORKING/$PAGENAME.wiki"

# handle 3 column tables
sed -i "s/^||\(.*\)||\(.*\)||\(.*\)||/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr>/g" "$WORKING/$PAGENAME.wiki"

# handle 2 column tables
sed -i "s/^||\(.*\)||\(.*\)||/<tr><td>\1<\/td><td>\2<\/td><\/tr>/g" "$WORKING/$PAGENAME.wiki"

# add <table> to start of table
perl -0777 -i -pe 's/[^>]\r\n<tr>/\r\n<table>\r\n<tr>/g' "$WORKING/$PAGENAME.wiki"

# add </table> to end of table
perl -0777 -i -pe 's/<\/tr>\r\n[^<]/<\/tr>\r\n<\/table>/g' "$WORKING/$PAGENAME.wiki"

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


