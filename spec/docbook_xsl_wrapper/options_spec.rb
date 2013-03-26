require 'spec_helper'

module DocbookXslWrapper
  describe Options do

    describe "#parse" do
      it "should set some defaults" do
        options = Options.parse(['etext.xml'])
        options.css.should be nil
        options.customization.should be nil
        options.fonts.should eql []
        options.format.should eq 'epub'
        options.output.should match /etext\.epub\z/
        options.debug.should be false
        options.verbose.should be false
      end
      it "should assign docbook with the XML file path" do
        options = Options.parse(['etext.xml'])
        options.docbook.should match /etext\.xml\z/
      end
      it "should set the EPUB output filename from the XML filename" do
        options = Options.parse(['/path/to/etext.xml'])
        options.output.should eql '/path/to/etext.epub'
      end

      context "when verbose option" do
        it "should set verbose to true" do
          options = Options.parse(['--verbose', 'etext.xml'])
          options.verbose.should be true
        end
      end
      context "when debug option" do
        it "should set debug to true" do
          options = Options.parse(['--debug', 'etext.xml'])
          options.debug.should be true
        end
        it "should set verbose to true" do
          options = Options.parse(['--debug', 'etext.xml'])
          options.verbose.should be true
        end
      end
      context "when css option used" do
        it "should assign value to .css" do
          options = Options.parse(['--css', 'stylesheet.css', 'etext.xml'])
          options.css.should match /stylesheet\.css\z/
        end
      end
      context "when customization stylsheet given option" do
        it "should set .stylesheet with the value" do
          options = Options.parse(['--stylesheet', 'some.xsl', 'etext.xml'])
          options.stylesheet.should match /some\.xsl\z/
        end
      end
      context "when fonts option" do
        it "should sets fonts with the OTF files" do
          options = Options.parse(['--font', 'one.otf', '--font', 'two.otf', 'etext.xml'])
          options.fonts[0].should match /one\.otf\z/
          options.fonts[1].should match /two\.otf\z/
        end
      end
      context "when output file given" do
        it "should assign output with the path/filename" do
          options = Options.parse(['--output', '/path/to/new.epub', 'etext.xml'])
          options.output.should eq '/path/to/new.epub'
        end
      end
      context "when output ebook format is given" do
        it "should assign format with the given book format" do
          options = Options.parse(['--type', 'ePub3', 'etext.xml'])
          options.format.should eq 'epub3'
        end
      end
    end

  end
end
