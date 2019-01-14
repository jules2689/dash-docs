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
rm -rf docs/git-scm.docset

# Make docset folder and copy in HTML
mkdir -p docs/git-scm.docset/Contents/Resources/Documents/

# Add Plist
cp generator/git-scm/default.plist docs/git-scm.docset/Contents/info.plist

# Add Icon
cp generator/git-scm/git.png docs/git-scm.docset/icon.png

# Make sqlite DB and rename files for dash
BUNDLE_GEMFILE=generator/git-scm/Gemfile bundle exec ruby generator/git-scm/sqlite_db.rb
sqlite3 docs/git-scm.docset/Contents/Resources/docSet.dsidx < generator/git-scm/sqlite.sql
rm sqlite.sql

# copy over fresh files
cp -R generator/git-scm/website/* docs/git-scm.docset/Contents/Resources/Documents/
tar --exclude='.DS_Store' -cvzf docs/git-scm.tgz docs/git-scm.docset
rm -rf docs/git-scm.docset

# Bump version number
ruby -e "c = File.read('docs/gitscm.xml'); v = c.match(/<version>(\d+\.\d+)/)[1]; c.gsub!(v, (v.to_f + 0.1).to_s); File.write('docs/gitscm.xml', c)"
