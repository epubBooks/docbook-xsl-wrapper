require 'fileutils'
require 'rexml/parsers/pullparser'

module DocbookXslWrapper

  class Epub
    attr_reader :options, :xml

    def initialize(options)
      @options = options
      @xml     = Nokogiri::XML(File.open(@options.docbook, 'rb'))
    end

    def create
      # Nokogiri doesn't create directories, so we do it manually
      Dir.mkdir(File.join(options.destination, meta_inf_directory))
      Dir.mkdir(File.join(options.destination, oebps_directory))

      render_to_epub
      bundle_epub
    end

  private

    def render_to_epub
      errors = xslt_transform_and_rescue_because_it_currently_throws_unknown_runtime_error
      raise "Could not render as .epub to #{options.output}\n\n(#{errors})" unless errors.empty?
    end

    def xslt_transform_and_rescue_because_it_currently_throws_unknown_runtime_error
      begin
        errors = stylesheet.transform(xml, params)
      rescue
        errors = ''
      end
      errors
    end

    def stylesheet
      xsl = docbook_xsl_path
      xsl = options.stylesheet unless options.stylesheet.empty?

      Nokogiri::XSLT(File.open(xsl, 'rb'))
    end

    def docbook_xsl_path
      case options.format
      when 'epub3'
        File.join(GEM_PATH, 'xsl', 'epub3', 'chunk.xsl')
      else
        File.join(GEM_PATH, 'xsl', 'epub', 'docbook.xsl')
      end
    end

    def params
      params_list = [
        'chunk.quietly', "#{verbosity}",
        'chunk.first.sections', 1,
        'othercredit.like.author.enabled', 1,
        'chapter.autolabel', 0,
        'section.autolabel', 0,
        'part.autolabel', 0,
        'base.dir', File.join(options.destination, '/'),
      ]
      params_list.concat(css) if options.css
      params_list.concat(fonts) unless options.fonts.empty?

      Nokogiri::XSLT.quote_params(params_list)
    end

    def fonts
      ['epub.embedded.fonts', options.fonts.map {|f| File.basename(f)}.join(',')]
    end

    def css
      ['html.stylesheet', File.join(File.basename(options.css), '/')]
    end

    def bundle_epub
      copy_media_files_to_epub_dir
      create_mimetype_file if options.format == 'epub' # EPUB3 stylesheet creates this automatically

      quiet = options.verbose ? '' : '-q'
      # Double-quote stylesheet & file to help Windows cmd.exe
      zip_cmd = %Q(cd "#{options.destination}" && zip #{quiet} -X -r  "#{File.expand_path(options.output)}" "mimetype" "#{meta_inf_directory}" "#{oebps_directory}")

      puts zip_cmd if options.debug
      success = system(zip_cmd)
      raise "Could not bundle into .epub file to #{options.output}" unless success
    end

    def create_mimetype_file
      filename = File.join(options.destination, "mimetype")
      File.open(filename, "w") {|f| f.print "application/epub+zip"}
      File.basename(filename)
    end

    def copy_media_files_to_epub_dir
      copy_fonts
      copy_css
      copy_images

      # Callouts disabled in this release until more testing can be done
      #copy_callouts
    end

    def copy_fonts
      return if options.fonts.empty?

      font_directory = File.join(options.destination, oebps_directory, 'fonts')
      Dir.mkdir(font_directory)

      options.fonts.each do |font|
        FileUtils.cp(font, File.join(font_directory, File.basename(font)))
      end
    end

    def copy_css
      return unless options.css

      FileUtils.cp(options.css, File.join(options.destination, oebps_directory, File.basename(options.css)))
    end

    def copy_images
      xml_image_references.each do |image|
        copy_image(image)
      end
    end

    def xml_image_references
      refs = Array.new
      xml.xpath('//xmlns:imagedata', '//xmlns:graphic', 'xmlns' => 'http://docbook.org/ns/docbook').each do |node|
        img = node.attribute('fileref').value
        refs << img if is_valid_image?(img)
      end

      refs.uniq
    end

    def is_valid_image?(image)
      return true if File.extname(image).match(/\.(jpe?g|png|gif|svg|xml)\z/i)
      false
    end

    def copy_image(image)
      source      = File.join(File.dirname(options.docbook), image)
      destination = File.join(options.destination, oebps_directory, image)

      FileUtils.mkdir_p(File.dirname(destination))

      puts "Copying image: #{source} to #{destination}" if options.debug
      FileUtils.cp(source, destination)
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

    def verbosity
      return 0 if options.verbose == true
      return 1
    end


    # TODO: This method is not being called for the moment....needs to be tested
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

    def has_callouts?
      parser = REXML::Parsers::PullParser.new(File.new(@collapsed_docbook_file))
      while parser.has_next?
        element = parser.pull
        return true if element.start_element? and (element[0] == "calloutlist" or element[0] == "co")
      end
      false
    end

  end
end
