# Download full webpage
if [[ "$1" == "--use-backup" ]]; then
  echo "Using back up"
  rm -rf generator/git-scm/website
  cp -R generator/git-scm/website-bak generator/git-scm/website
else 
  rm -rf generator/git-scm/website
  rm -rf generator/git-scm/website-bak

  mkdir generator/git-scm/website
  pushd generator/git-scm/website
  wget \
       --recursive \
       --no-clobber \
       --page-requisites \
       --html-extension \
       --convert-links \
       --restrict-file-names=windows \
       --domains git-scm.com \
       --no-parent \
       git-scm.com/book/en/v2
  popd

  cp -R generator/git-scm/website generator/git-scm/website-bak
fi

# Remove old docset
rm -rf doc/git-scm.docset

# Make docset folder and copy in HTML
mkdir -p doc/git-scm.docset/Contents/Resources/Documents/

# Add Plist
cp generator/git-scm/default.plist doc/git-scm.docset/Contents/info.plist

# Add Icon
cp generator/git-scm/git.png doc/git-scm.docset/icon.png

# Make sqlite DB and rename files for dash
BUNDLE_GEMFILE=generator/git-scm/Gemfile bundle exec ruby generator/git-scm/sqlite_db.rb
sqlite3 doc/git-scm.docset/Contents/Resources/docSet.dsidx < generator/git-scm/sqlite.sql
rm sqlite.sql

# copy over fresh files
cp -R generator/git-scm/website/* doc/git-scm.docset/Contents/Resources/Documents/
tar --exclude='.DS_Store' -cvzf doc/git-scm.tgz doc/git-scm.docset
rm -rf doc/git-scm.docset

# Bump version number
ruby -e "c = File.read('doc/gitscm.xml'); v = c.match(/<version>(\d+\.\d+)/)[1]; c.gsub!(v, (v.to_f + 0.1).to_s); File.write('doc/gitscm.xml', c)"
