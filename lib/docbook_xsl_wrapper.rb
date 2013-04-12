require 'nokogiri'

require 'docbook_xsl_wrapper/epub'
require 'docbook_xsl_wrapper/options'
require 'docbook_xsl_wrapper/validate'

require "docbook_xsl_wrapper/version"

module DocbookXslWrapper
  GEM_PATH = File.expand_path(File.join('..', '..'), __FILE__)
end
