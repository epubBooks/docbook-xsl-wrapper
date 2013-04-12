require 'spec_helper'

module DocbookXslWrapper
  describe Validate do

    let(:good_xml) {
      '<?xml version="1.0" encoding="utf-8"?>
      <book xmlns="http://docbook.org/ns/docbook" version="5.0">
        <title>My First Book</title>
        <chapter>
          <title>Chapter 1</title>
          <para>Paragraph.</para>
        </chapter>
      </book>'
    }

    let(:bad_xml) {
      '<?xml version="1.0" encoding="utf-8"?>
      <book xmlns="http://docbook.org/ns/docbook" version="5.0">
        <title>My First Book</title>
        <chapter/>
      </book>'
    }

    context "when given valid XML" do
      let(:valid_doc) { DocbookXslWrapper::Validate.new(good_xml) }

      describe "#valid?" do
        it "should return true" do
          valid_doc.valid?.should be true
        end
      end

      describe "#errors" do
        it "should have an empty errors list" do
          valid_doc.valid?
          valid_doc.errors.should be_empty
        end
      end
    end

    context "when given bad XML" do
      let(:invalid_doc) { DocbookXslWrapper::Validate.new(bad_xml) }

      describe "#valid?" do
        it "should return false" do
          invalid_doc.valid?.should be false
        end
      end

      describe "#errors" do
        before(:each) { invalid_doc.valid? }

        it "should not be empty" do
          invalid_doc.errors.should_not be_empty
        end
        it "should provide a list of validation errors" do
          invalid_doc.errors.count.should be 5
        end
      end
    end

  end
end
