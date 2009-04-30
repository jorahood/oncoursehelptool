class KbDoc
  include CommonMethods
  #  include JXslt
 
  attr_reader :docid, :rest_path
  attr_accessor :xml, :html, :hashed
  
  def initialize(docid)
    @docid = docid
    @rest_path = 
      "/REST/v0.2/#{ConfigFile[:domain_class]}/document/" + 
      "#{ConfigFile[:audience]}/#@docid.xml?domain=#{ConfigFile[:domain]}"
    check_docid
  end
  
  def retrieve_text
    @xml = request_xml
    @hashed = xml_to_hash 
    check_for_kb_errors
    @html = transform_xml_to_html    
  end

  def check_docid
    unless @docid.match(/^[a-z]{4}$/)
      index = ToolIndexDoc.new
      @docid = index.lookup(@docid)
    end
  end
end