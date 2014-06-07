#encoding: utf-8

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# requires
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
require 'open-uri'
require 'nokogiri'
require 'pathname'
require 'fileutils'
require 'uri'
require File.expand_path(File.dirname(__FILE__)) + '/get_doc.rb'

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# download function
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

def download_one(url_or_uri)
  # URI object
  uri = url_or_uri
  if uri.class == String
    uri = resolve_as_uri(url_or_uri)
  end
  puts "uri = #{uri.to_s}"

  # Source information
  source_uri = get_source_uri(uri)
  pathname = get_pathname(uri)
  puts "source_uri = #{source_uri.to_s}"
  puts "pathname = #{pathname.to_s}"
  puts "pathname.dirname = #{pathname.dirname.to_s}"
  puts "pathname.basename = #{pathname.basename.to_s}"

  # download
  doc = get_doc(source_uri)
  content = doc.search('#wpTextbox1').text

  # mkdir
  puts "mkdir #{pathname.dirname.to_s} ..."
  FileUtils.mkdir_p pathname.dirname.to_s

  # save
  puts "save to #{pathname.to_s} ..."
  File.write(pathname.to_s, content)
end

# @return [URI::HTTP]
def get_source_uri(uri)
  m = uri.to_s.match(/^(.+\/index\.php)\/(.+)$/)
  raise "Can't make source uri from #{uri.to_s}" unless m
  baseurl = m[1]
  pagename = m[2]
  url = "#{baseurl}?title=#{pagename}&action=edit"
  return URI(url)
end

# @return [Pathname]
def get_pathname(uri)
  m = uri.to_s.match(/^(.+\/index\.php)\/(.+)$/)
  raise "Can't make folder name from #{uri.to_s}" unless m
  baseurl = m[1]
  pagename = URI.unescape(m[2])
  Pathname.new("#{uri.host}/#{pagename}.mediawiki").expand_path
end

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# Test
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
if $0 == __FILE__
  url = ARGV[0]
  if url
    puts "----test----"
    download_one(url)
  end
end
