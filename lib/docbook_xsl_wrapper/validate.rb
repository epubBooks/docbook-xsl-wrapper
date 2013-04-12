module DocbookXslWrapper
  class Validate
    attr_accessor :errors

    attr_reader :document, :schema
    private :document, :schema

    def initialize(xml)
      @document = Nokogiri::XML(xml)
      @schema   = Nokogiri::XML::RelaxNG(File.open(File.join(GEM_PATH, 'schema', 'docbookxi.rng'), 'rb'))
      @errors   = ''
    end

    def valid?
      @errors = schema.validate(document)

      return true if errors.empty?
      false
    end

  end
end
