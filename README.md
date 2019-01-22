# moin2confluence

This script can be used to migrate MoinMoin wiki pages to Confluence

I recommend running this on your Confluence server because the files must be on the same server as Confluence to import them.
You can tar up the moinmoin wiki files and copy them to the Confluence server.

# Caveats
 * Tables do not work right
 * I have not tested base64 embedded images and I'm sure linked images uploaded to MoinMoin will not work
 * If a page was a sub page it will no longer be a sub page. The link should still work but you have to manually move it so it does not show up in the list of root pages.

# Install

    # On ubuntu run these commands to install pandoc to convert between document formats
    sudo apt install pandoc

# Converting one page

Syntax: 

    ./moin2confluence.sh <PageName> <wiki root> <output dir>

Example: 

    ./moin2confluence.sh Certificates /data/webs/DVTech outputdir

The wiki root directory should be the one that contains the data directory

# Converting all pages in moin moin wiki

You can invoke this bash script to call the script for each page:

    for PAGE in `ls /webs/wiki/data/pages`; do echo $file; ~/moin2confluence/convert.sh "$PAGE" /webs/wiki/ output/; done

# Importing pages into Confluence
After running the script login to Confluence and go to Space Tools > Content Tools > Import, enter the path to the output directory and click Import

# How it works
 * MoinMoin syntax is pretty close to mediawiki syntax so we convert to that first
 * We use pandoc to convert from mediawiki to markdown
 * Then we use the modified confluence.lua Custom Writer to convert from markdown to Confluence Storage Format
 * Finally you use Confluence Site Tools Import to import the Confluence Storage Format files

# Credits

Used the code in here to see how to extract a moinmoin page source code: https://github.com/tetelle/moin

Forked and modified this confluence lua script to get from markdown to Confluence: https://github.com/jpbarrette/pandoc-confluence-writer/raw/master/confluence.lua

