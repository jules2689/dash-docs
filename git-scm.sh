# Download full webpage
# rm -rf website
# mkdir website
# pushd website
# wget \
#      --recursive \
#      --no-clobber \
#      --page-requisites \
#      --html-extension \
#      --convert-links \
#      --restrict-file-names=windows \
#      --domains git-scm.com \
#      --no-parent \
#      git-scm.com/book/en/v2
# popd

# cp -R website website-bak

rm -rf website
cp -R website-bak website

# Remove old docset
rm -rf doc/git-scm.docset

# Make docset folder and copy in HTML
mkdir -p doc/git-scm.docset/Contents/Resources/Documents/

# Add Plist
cp default.plist  doc/git-scm.docset/Contents/info.plist

# Add Icon
cp git.png  doc/git-scm.docset/icon.png

# Make sqlite DB and rename files for dash
bundle exec ruby sqlite_db.rb
sqlite3  doc/git-scm.docset/Contents/Resources/docSet.dsidx < sqlite.sql
rm sqlite.sql

# copy over fresh files
cp -R website/* doc/git-scm.docset/Contents/Resources/Documents/
tar --exclude='.DS_Store' -cvzf  doc/git-scm.tgz  doc/git-scm.docset
rm -rf doc/git-scm.docset
