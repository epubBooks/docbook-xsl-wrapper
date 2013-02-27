require 'fileutils'
require 'rexml/parsers/pullparser'

module DocbookXslWrapper

  class Epub
    attr_reader :destination

    def initialize(args)
      @docbook     = args[:options].docbook
      @destination = args[:destination] || ".epubtmp#{Time.now.to_f.to_s}"
      @css         = args[:options].css
      @fonts       = args[:options].fonts

      @oebps_directory    = File.join(@destination, 'OEBPS')
      @meta_inf_directory = File.join(@destination, 'META-INF')

      docbook_uri         = 'http://docbook.sourceforge.net/release/xsl/current'
      @callout_path       = File.join('images', 'callouts')
      @callout_full_path  = File.join(docbook_uri, @callout_path)
      @callout_limit      = 15
      @callout_ext        = '.png'
      @to_delete          = []

      if args[:options].customization
        @stylesheet = File.expand_path(args[:options].customization)
      else
        @stylesheet = File.join(docbook_uri, 'epub', 'docbook.xsl')
      end
    end

    def render_to_file(output_file, verbose=false)
      render_to_epub(output_file, verbose)
      bundle_epub(output_file, verbose)
    end

  private

    def render_to_epub(output_file, verbose)
      @collapsed_docbook_file = collapse_docbook()

      chunk_quietly =   "--stringparam chunk.quietly " + (verbose ? '0' : '1')
      co_path =    "--stringparam callout.graphics.path #{@callout_path}/"
      co_limit =   "--stringparam callout.graphics.number.limit #{@callout_limit}"
      co_ext =     "--stringparam callout.graphics.extension #{@callout_ext}"
      html_stylesheet = "--stringparam html.stylesheet #{File.basename(@css)}" if @css
      base =            "--stringparam base.dir #{@oebps_directory}/"
      unless @fonts.empty?
        fonts = @fonts.map {|f| File.basename(f)}.join(',')
        font =            "--stringparam epub.embedded.fonts \"#{fonts}\""
      end
      meta =            "--stringparam epub.metainf.dir #{@meta_inf_directory}/"
      oebps =           "--stringparam epub.oebps.dir #{@oebps_directory}/"
      options = [chunk_quietly,
                 co_path,
                 co_limit,
                 co_ext,
                 base,
                 font,
                 meta,
                 oebps,
                 html_stylesheet,
                ].join(" ")
      # Double-quote stylesheet & file to help Windows cmd.exe
      db2epub_cmd = %Q(cd "#{@destination}" && xsltproc #{options} "#{@stylesheet}" "#{@collapsed_docbook_file}")
      STDERR.puts db2epub_cmd if $DEBUG
      success = system(db2epub_cmd)
      raise "Could not render as .epub to #{output_file} (#{db2epub_cmd})" unless success
      @to_delete << Dir["#{@meta_inf_directory}/*"]
      @to_delete << Dir["#{@oebps_directory}/*"]
    end

    def bundle_epub(output_file, verbose)
      quiet = verbose ? "" : "-q"
      mimetype_filename = write_mimetype()
      meta   = File.basename(@meta_inf_directory)
      oebps  = File.basename(@oebps_directory)
      images = copy_images()
      csses  = copy_csses()
      fonts  = copy_fonts()
      callouts = copy_callouts()
      # zip -X -r ../book.epub mimetype META-INF OEBPS
      # Double-quote stylesheet & file to help Windows cmd.exe
      zip_cmd = %Q(cd "#{@destination}" && zip #{quiet} -X -r  "#{File.expand_path(output_file)}" "#{mimetype_filename}" "#{meta}" "#{oebps}")
      puts zip_cmd if $DEBUG
      success = system(zip_cmd)
      raise "Could not bundle into .epub file to #{output_file}" unless success
    end

    def collapse_docbook
      # Input must be collapsed because REXML couldn't find figures in files that
      # were XIncluded or added by ENTITY
      #   http://sourceforge.net/tracker/?func=detail&aid=2750442&group_id=21935&atid=373747

      # Double-quote stylesheet & file to help Windows cmd.exe
      collapsed_file = File.join(File.expand_path(File.dirname(@docbook)),
                                 '.collapsed.' + File.basename(@docbook))
      entity_collapse_command = %Q(xmllint --loaddtd --noent -o "#{collapsed_file}" "#{@docbook}")
      entity_success = system(entity_collapse_command)
      raise "Could not collapse named entites in #{@docbook}" unless entity_success

      xinclude_collapse_command = %Q(xmllint --xinclude -o "#{collapsed_file}" "#{collapsed_file}")
      xinclude_success = system(xinclude_collapse_command)
      raise "Could not collapse XIncludes in #{@docbook}" unless xinclude_success

      @to_delete << collapsed_file
      return collapsed_file
    end

    def copy_callouts
      new_callout_images = []
      if has_callouts?
        calloutglob = "#{@callout_full_path}/*#{@callout_ext}"
        Dir.glob(calloutglob).each {|img|
          img_new_filename = File.join(@oebps_directory, @callout_path, File.basename(img))

          # TODO: What to rescue for these two?
          FileUtils.mkdir_p(File.dirname(img_new_filename))
          FileUtils.cp(img, img_new_filename)
          @to_delete << img_new_filename
          new_callout_images << img
        }
      end
      return new_callout_images
    end

    def copy_fonts
      new_fonts = []
      @fonts.each {|font_file|
        font_new_filename = File.join(@oebps_directory, File.basename(font_file))
        FileUtils.cp(font_file, font_new_filename)
        new_fonts << font_file
      }
      return new_fonts
    end

    def copy_csses
      if @css
        css_new_filename = File.join(@oebps_directory, File.basename(@css))
        FileUtils.cp(@css, css_new_filename)
      end
    end

    def copy_images
      image_references = get_image_refs()
      new_images = []
      image_references.each {|img|
        # TODO: It'd be cooler if we had a filetype lookup rather than just
        # extension
        if img =~ /\.(svg|png|gif|jpe?g|xml)/i
          img_new_filename = File.join(@oebps_directory, img)
          img_full = File.join(File.expand_path(File.dirname(@docbook)), img)

          # TODO: What to rescue for these two?
          FileUtils.mkdir_p(File.dirname(img_new_filename))
          puts(img_full + ": " + img_new_filename) if $DEBUG
          FileUtils.cp(img_full, img_new_filename)
          @to_delete << img_new_filename
          new_images << img_full
        end
      }
      return new_images
    end

    def write_mimetype
      mimetype_filename = File.join(@destination, "mimetype")
      File.open(mimetype_filename, "w") {|f| f.print "application/epub+zip"}
      @to_delete << mimetype_filename
      return File.basename(mimetype_filename)
    end

    # Returns an Array of all of the (image) @filerefs in a document
    def get_image_refs
      parser = REXML::Parsers::PullParser.new(File.new(@collapsed_docbook_file))
      image_refs = []
      while parser.has_next?
        el = parser.pull
        if el.start_element? and (el[0] == "imagedata" or el[0] == "graphic")
          image_refs << el[1]['fileref']
        end
      end
      return image_refs.uniq
    end

    # Returns true if the document has code callouts
    def has_callouts?
      parser = REXML::Parsers::PullParser.new(File.new(@collapsed_docbook_file))
      while parser.has_next?
        el = parser.pull
        if el.start_element? and (el[0] == "calloutlist" or el[0] == "co")
          return true
        end
      end
      return false
    end

  end
end
