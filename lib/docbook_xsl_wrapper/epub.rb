require 'fileutils'
require 'rexml/parsers/pullparser'

module DocbookXslWrapper

  class Epub
    attr_reader :options

    def initialize(options)
      @options = options

      case options.format
      when 'epub3'
        xsl = File.join('epub3', 'chunk.xsl')
      else
        xsl = File.join('epub', 'docbook.xsl')
      end
      official_docbook_xsl = File.join('http://docbook.sourceforge.net/release/xsl/current', xsl)

      @options.stylesheet = official_docbook_xsl unless options.stylesheet
    end

    def create
      begin
        render_to_epub
        bundle_epub
      ensure
        FileUtils.remove_entry_secure @collapsed_docbook_file
      end
    end

  private

    def render_to_epub
      @collapsed_docbook_file = collapse_docbook

      # Double-quote stylesheet & file to help Windows cmd.exe
      db2epub_cmd = %Q(cd "#{options.destination}" && xsltproc #{xsl_parser_options} "#{options.stylesheet}" "#{@collapsed_docbook_file}")
      STDERR.puts db2epub_cmd if options.debug
      success = system(db2epub_cmd)
      raise "Could not render as .epub to #{options.output} (#{db2epub_cmd})" unless success
    end

    def xsl_parser_options
      chunk_quietly = "--stringparam chunk.quietly 1" if options.verbose == false
      css           = "--stringparam html.stylesheet #{File.basename(options.css)}/" if options.css
      base          = "--stringparam base.dir #{oebps_path}/"
      unless options.fonts.empty?
        fonts = options.fonts.map {|f| File.basename(f)}.join(',')
        font  = "--stringparam epub.embedded.fonts \"#{fonts}\""
      end
      meta  = "--stringparam epub.metainf.dir #{meta_inf_directory}/"
      oebps = "--stringparam epub.oebps.dir #{oebps_directory}/"

      [
        chunk_quietly,
        base,
        font,
        meta,
        oebps,
        css,
      ].join(" ")
    end

    def collapse_docbook
      # Input must be collapsed because REXML couldn't find figures in files that
      # were XIncluded or added by ENTITY
      #   http://sourceforge.net/tracker/?func=detail&aid=2750442&group_id=21935&atid=373747

      # Double-quote stylesheet & file to help Windows cmd.exe
      collapsed_file = File.join(File.expand_path(File.dirname(options.docbook)),
                                 '.collapsed.' + File.basename(options.docbook))
      entity_collapse_command = %Q(xmllint --loaddtd --noent -o "#{collapsed_file}" "#{options.docbook}")
      entity_success = system(entity_collapse_command)
      raise "Could not collapse named entites in #{options.docbook}" unless entity_success

      xinclude_collapse_command = %Q(xmllint --xinclude -o "#{collapsed_file}" "#{collapsed_file}")
      xinclude_success = system(xinclude_collapse_command)
      raise "Could not collapse XIncludes in #{options.docbook}" unless xinclude_success

      collapsed_file
    end

    def bundle_epub
      quiet = options.verbose ? "" : "-q"
      mimetype_filename = write_mimetype
      images = copy_images
      csses  = copy_css
      fonts  = copy_fonts
      callouts = copy_callouts
      # zip -X -r ../book.epub mimetype META-INF OEBPS
      # Double-quote stylesheet & file to help Windows cmd.exe
      zip_cmd = %Q(cd "#{options.destination}" && zip #{quiet} -X -r  "#{File.expand_path(options.output)}" "#{mimetype_filename}" "#{meta_inf_directory}" "#{oebps_directory}")
      puts zip_cmd if options.debug
      success = system(zip_cmd)
      raise "Could not bundle into .epub file to #{options.output}" unless success
    end

    def write_mimetype
      filename = File.join(options.destination, "mimetype")
      File.open(filename, "w") {|f| f.print "application/epub+zip"}
      File.basename(filename)
    end

    def copy_callouts
      return unless has_callouts?

      images = Array.new
      calloutglob = "#{options.callout_full_path}/*#{options.callout_ext}"
      Dir.glob(calloutglob).each do |image|
        new_filename = File.join(oebps_path, options.callout_path, File.basename(image))

        # TODO: What to rescue for these two?
        FileUtils.mkdir_p(File.dirname(new_filename))
        FileUtils.cp(image, new_filename)
        images << image
      end
      images
    end

    # Returns true if the document has code callouts
    def has_callouts?
      parser = REXML::Parsers::PullParser.new(File.new(@collapsed_docbook_file))
      while parser.has_next?
        element = parser.pull
        return true if element.start_element? and (element[0] == "calloutlist" or element[0] == "co")
      end
      false
    end

    def copy_fonts
      fonts = Array.new
      options.fonts.each {|font|
        new_filename = File.join(oebps_path, File.basename(font))
        FileUtils.cp(font, new_filename)
        fonts << font
      }
      fonts
    end

    def copy_css
      return unless options.css

      filename = File.join(oebps_path, File.basename(options.css))
      FileUtils.cp(options.css, filename)
    end

    def copy_images
      images = Array.new
      xml_image_references.each do |image|
        images << copy_image(image)
      end
      images
    end

    def copy_image(image)
      source_file      = File.join(File.expand_path(File.dirname(options.docbook)), image)
      destination_file = File.join(oebps_path, image)

      FileUtils.mkdir_p(File.dirname(destination_file))

      puts "Copying image: #{source_file} to #{destination_file}" if options.debug
      FileUtils.cp(source_file, destination_file)

      destination_file
    end

    def xml_image_references
      parser = REXML::Parsers::PullParser.new(File.new(@collapsed_docbook_file))
      references = Array.new
      while parser.has_next?
        element = parser.pull
        references << element[1]['fileref'] if is_valid_image_reference?(element)
      end
      references.uniq
    end

    def is_valid_image_reference?(element)
      return false unless element.start_element?
      return false unless element[0] == 'graphic' or element[0] == 'imagedata'
      return true if element[1]['fileref'].match(/\.(jpe?g|png|gif|svg|xml)\Z/i)
      false
    end

    def oebps_directory
      'OEBPS'
    end

    def oebps_path
      @oebps_path ||= File.join(options.destination, oebps_directory)
    end

    def meta_inf_directory
      'META-INF'
    end

  end
end
