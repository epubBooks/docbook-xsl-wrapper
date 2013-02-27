require 'spec_helper'

module DocbookXslWrapper
  describe Options do

    describe "#parse" do
      it "should set some defaults" do
        options = Options.parse(['etext.xml'])
        options.css.should be nil
        options.customization.should be nil
        options.fonts.should eql []
        options.output.should be nil
        options.debug.should be false
        options.verbose.should be false
      end
      it "should assign docbook with the XML file path" do
        options = Options.parse(['etext.xml'])
        options.docbook.should eql 'etext.xml'
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
          options.css.should eq 'stylesheet.css'
        end
      end
      context "when customization stylsheet given option" do
        it "should set .customiztion with the value" do
          options = Options.parse(['--stylesheet', 'some.xsl', 'etext.xml'])
          options.customization.should eq 'some.xsl'
        end
      end
      context "when fonts option" do
        it "should sets fonts with the OTF files" do
          options = Options.parse(['--font', 'one.otf', '--font', 'two.otf', 'etext.xml'])
          options.fonts.should eq ['one.otf', 'two.otf']
        end
      end
      context "when output file given" do
        it "should assign output with the path/filename" do
          options = Options.parse(['--output', '/path/to/new.epub', 'etext.xml'])
          options.output.should eq '/path/to/new.epub'
        end
      end
    end

  end
end
