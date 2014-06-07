#encoding: utf-8

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# requires
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
require 'open-uri'
require 'nokogiri'

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #
# utils
# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- #

# basic authentication
$certs = nil
if ENV["BASIC_USER"] || ENV["BASIC_PASS"]
  $certs = [ENV["BASIC_USER"] || "", ENV["BASIC_PASS"] || ""]
end

# basic authentication
$certs = nil
if ENV["BASIC_USER"] || ENV["BASIC_PASS"]
  $certs = [ENV["BASIC_USER"] || "", ENV["BASIC_PASS"] || ""]
end

# @return [URI::HTTP]
def resolve_as_uri(url_or_uri)
  # URI object
  url = url_or_uri.to_s
  if url.match(/^https?\:/)
    uri = URI(url)
  else
    uri = URI.join($root_uri, url)
  end

  # First uri is root one
  $root_uri = uri unless $root_uri

  # result
  return uri
end

# Get url content and return doc object
def get_doc(url)
  # open-uri options
  options = {}
  if $certs
    options = {http_basic_authentication: $certs}
  end
  options[:redirect] = false;

  # URI object
  uri = resolve_as_uri(url)

  # open-uri
  charset = nil
  begin
    html = open(uri, options) do |f|
      charset = f.charset
      f.read
    end
  rescue OpenURI::HTTPRedirect => redirect
    dir("Redirection to other host") if uri.host != redirect.uri.host
    uri = redirect.uri
    retry
  end

  # parse
  return Nokogiri::HTML.parse(html, nil, charset)
end
