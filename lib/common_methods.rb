require 'net/http'
require 'rexml/document'
require 'xml/xslt'

module CommonMethods
  include Exceptions

  ConfigFile = YAML.load_file("#{RAILS_ROOT}/config/app_config.yml")
  YUI = 'http://yui.yahooapis.com/2.5.1/build'
  
  def request_xml
    http = Net::HTTP.new(ConfigFile[:server])
    http.start do |connection|
      action = Net::HTTP::Get.new(@rest_path)
      action.basic_auth(ConfigFile["username_#{RAILS_ENV}"], ConfigFile["password_#{RAILS_ENV}"])
      response = connection.request(action)
      response.value 
      response.body
    end 
  end
  
  def check_for_kb_errors
    if error = hashed['kberror']
      raise RetrievalFailure, error['message']
    end 
  end

  def xml_to_hash
    Hash.from_xml(self.xml)
  end

  def java_transform_xml_to_html
    transformer = JXslt::SaxonProc.new
    transformer.transform("#{RAILS_ROOT}/lib/XSLT/kbxml_to_html.xslt", xml)
  end
  
  def transform_xml_to_html
    xslt = XML::XSLT.new
    xslt.xsl = "#{RAILS_ROOT}/lib/XSLT/kbxml_to_html.xslt"
    xslt.xml = REXML::Document.new(self.xml)
    xslt.serve
  end
end
