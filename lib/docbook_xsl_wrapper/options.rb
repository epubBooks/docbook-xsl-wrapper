require 'optparse'
require 'ostruct'

module DocbookXslWrapper
  class Options

    def self.parse(args)
      options = OpenStruct.new
      options.docbook_xsl_root  = 'http://docbook.sourceforge.net/release/xsl/current'
      options.callout_path      = File.join('images', 'callouts')
      options.callout_full_path = File.join(options.docbook_xsl_root, options.callout_path)
      options.callout_limit     = 15
      options.callout_ext       = '.png'

      options.css               = nil
      options.stylesheet        = nil
      options.fonts             = []
      options.output            = nil
      options.debug             = false
      options.verbose           = false
      options.docbook           = nil

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{opts.program_name} [OPTIONS] [DocBook Files]"
        opts.separator ""
        opts.separator "#{opts.program_name} converts DocBook <book> and <article>s into to .epub files."
        opts.separator ""
        opts.separator ".epub is defined by the IDPF at www.idpf.org and is made up of 3 standards:"
        opts.separator "- Open Publication Structure (OPS)"
        opts.separator "- Open Packaging Format (OPF)"
        opts.separator "- Open Container Format (OCF)"
        opts.separator ""
        opts.separator "Specific options:"


        opts.on("-c", "--css [FILE]", "Use FILE for CSS on generated XHTML.") do |css|
          options.css = File.expand_path(css)
        end

        opts.on("-s", "--stylesheet [XSL FILE]", "Use XSL FILE as a stylesheet layer (imports epub/docbook.xsl).") do |xsl|
          options.stylesheet = File.expand_path(xsl)
        end

        opts.on("-f", "--font [OTF FILE]", "Embed OTF FILE in .epub.") do |otf|
          options.fonts << File.expand_path(otf)
        end

        opts.on("-o", "--output [OUTPUT FILE]", "Output EPUB file as OUTPUT FILE.") do |output|
          options.output = File.expand_path(output)
        end

        opts.separator ""

        opts.on("-d", "--[no-]debug", "Show debugging output.") do |d|
          options.debug = d
          options.verbose = d
        end

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options.verbose = v
        end


        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("--version", "Show version") do
          puts OptionParser::Version.join('.')
          exit
        end

      end

      args = ['-h'] if args.empty?
      opts.parse!(args)

      options.docbook = File.expand_path(args.first)
      unless options.docbook
        puts "No DocBook XML file(s) specified"
        exit
      end
      options.output = epub_filename_from_given_filename(options.docbook) unless options.output

      options
    end

  private

    def self.epub_filename_from_given_filename(filename)
      File.join(File.dirname(filename), File.basename(filename, File.extname(filename)) + ".epub")
    end

  end
end
