#encoding: utf-8

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# requires
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
require 'open-uri'
require 'nokogiri'
require './lib/download_one'
require './lib/get_doc'

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# usage
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
def usage
  puts "Usage: ruby mediawiki-downloader.rb <URL of MediaWiki index.php>"
  puts ""
  puts "Example: "
  puts "  $ ruby mediawiki-downloader.rb \"http://example.dev/mediawiki/index.php\""
  puts ""
  puts "Example with Basic Authentication:"
  puts "  $ BASIC_USER=john BASIC_PASS=xxx ruby mediawiki-downloader.rb \"http://example.dev/mediawiki/index.php\""
  puts ""
end

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# parameters
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
#url = 'http://www.yahoo.co.jp/'
url = ARGV[0]
unless url
  usage
  exit
end
puts "url = #{url}"

# All pages url
unless url.match(/^http.*\/index\.php$/)
  puts "Error: Specify URL of index.php"
  exit
end
url = "#{url}?title=Special:AllPages"
puts "all pages url = #{url}"

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Gathering page link addresses from Special:AllPages
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
$links = []
$gathered = []
def gather_links(url, nest)
  # Skip duplicated url gathering
  return if $gathered.include?(url)
  $gathered += [url]

  # Get from internet
  puts "[NEST #{nest}] getting #{url} ...";
  doc = get_doc(url)
  puts "title: #{doc.title}"

  # Get page links
  page_hrefs = doc.search(".mw-allpages-table-chunk a").map {|a| a[:href]}
  page_hrefs.uniq!
  $links += page_hrefs;

  # If no page links, attempt to get sub allpages
  if page_hrefs.size == 0
    puts "Attempt to get sub allpages ..."
    sub_hrefs = doc.search(".allpageslist a").map {|a| a[:href]}
    sub_hrefs.uniq!
    sub_hrefs.each do |href|
      gather_links(href, nest + 1)
    end
  end
end
gather_links(url, 0)
$links.uniq!

puts "---- Gathering result (#{$links.size}) ----"
$links.each do |link|
  puts link
end

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Confirming
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
while true do
  # Prompt for downloading
  puts "#{$links.size} items detected. Are you sure you want to download them? (y/n)"
  print "> "
  ans = STDIN.gets
  # switch
  if ans.match(/^y$/i)
    break
  elsif  ans.match(/^n$/i)
    exit
  else
    next # Re-input
  end
end

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Downloading
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
n = $links.size
puts "----downloading #{n} items----"
$links.each_with_index do |link, i|
  uri = resolve_as_uri(link)
  puts "--downloading [#{i}/#{n}] #{uri.to_s}--"
  puts "sleeping 1sec ..."
  sleep 1
  download_one(uri)
  puts "#{i}/#{n} done."
end
puts "All #{n} items finished."
