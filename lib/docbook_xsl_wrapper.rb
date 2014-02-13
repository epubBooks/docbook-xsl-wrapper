require 'nokogiri'

require 'docbook_xsl_wrapper/epub'
require 'docbook_xsl_wrapper/options'
require 'docbook_xsl_wrapper/validate'

require "docbook_xsl_wrapper/version"

module DocbookXslWrapper
  GEM_PATH = File.expand_path(File.join('..', '..'), __FILE__)

  def self.build_epub(options)
    tmp_dir = Dir.mktmpdir
    options.destination = tmp_dir

    begin
      puts "Rendering DocBook file #{options.docbook} to #{options.output}\n\n" if options.verbose

      epub = Epub.new(options)
      epub.create
    ensure
      FileUtils.remove_entry_secure tmp_dir
    end
  end

end
