require 'cgi'

def divide
  puts "=" * 80
  puts "=" * 80
  puts "=" * 80
end

# Generate docs
unless ARGV.include?('--skip-gen')
  use_bak = ARGV.include?('--use-backup')
  Dir.glob('generator/*/generate.sh').each do |d|
    cmd = "/bin/bash #{d}"
    cmd << " --use-backup" if use_bak
    system(cmd)
    divide
  end
end

# Generate index
puts "Writing out index.html file"
Dir.chdir('docs') do
  available_docs = Dir.glob('*.xml').map do |d|
    url = "https://jules2689.github.io/dash-docs/#{d}"
    "<li class=\"list-group-item\"><a href=\"dash-feed://#{CGI.escape(url)}\">#{d} => dash-feed://#{CGI.escape(url)}</a></li>"
  end.join("\n")

  html=<<~HTML
  <html>
  <head>
    <title>Dash Docset Feeds</title>
    <link href="/dash-docs/bootstrap.min.css" rel="stylesheet">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body>
    <div class="container">
      <h1>Dash Docset Feeds</h1>
       <ul class="list-group">
        #{available_docs}
      </ul>
    </div>
  </body>
  </html>
  HTML

  File.write('index.html', html)
end