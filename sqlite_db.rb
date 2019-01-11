require 'nokogiri'
require 'set'
require 'uri'
require 'byebug'

titles = Set.new
sections = {}

def dashTag(type, title, category = nil)
  tag = "<a name=\"//%s/%s/%s\" class=\"dashAnchor\"></a>"
  ref = category ? "apple_ref_#{category}" : "apple_ref"
  tag % [ref, type, title]
end

File.open('sqlite.sql', 'w') do |f|
  f.puts "CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"

  Dir.chdir('website') do
    files = Dir.glob("**/*.html")
    files.each do |file|
      content = File.read(file)
      doc = Nokogiri::HTML(content)
      fname = file.gsub("%3A", '_')

      # process title
      title_element = doc.css("h1").first
      title = title_element.text

      if file !~ /_.*?\.html/ && !titles.include?(title)
        titles << title
        content.gsub!(title_element.to_s, "#{dashTag('Guide', URI.escape(title))}\n#{title_element.to_s}")
        puts "#{fname} => #{title}"
        f.puts "INSERT INTO searchIndex VALUES (NULL, '#{title}', 'Guide', '#{fname}');"
      end

      # sections
      sections[title] ||= Set.new
      doc.css("#main h2").each do |h2|
        content.gsub!(h2.to_s, "#{dashTag('Section', URI.escape(h2.text))}\n#{h2.to_s}")
        next if sections[title].include?(h2.text)
        sections[title] << h2.text
        f.puts "INSERT INTO searchIndex VALUES (NULL, '#{h2.text}', 'Section', '#{fname}');"
      end

      # Write out gsubbed content
      File.write(fname, content)
    end
  end
end
