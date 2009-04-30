require File.dirname(__FILE__) + '/../spec_helper'

include Exceptions
describe KbDoc do
  
  before(:each) do
    @docid = 'atjv'
    @xml = File.read("#{FIXTURES}/doc_1.xml")
    @xml_error = File.read("#{FIXTURES}/doc_error.xml")
    @html = File.read("#{FIXTURES}/doc_1.html")
    @doc = KbDoc.new(@docid)
    @doc.xml = @xml
  end

  describe "docid attribute" do

    it "should exist" do
      @doc.docid.should == @docid
    end
  
    it "should be required" do
      lambda {
        KbDoc.new
      }.should raise_error(ArgumentError)
    end

    it "should automatically convert a tool name to a docid" do
      doc = KbDoc.new('sakai.assignment.grades')
      doc.docid.should == 'argj'
    end
    
  end

  describe 'retrieving xml' do

    it "should request xml" do
      @doc.request_xml.should match(/<docid>atjv<\/docid>/)
    end

    it "should create a hash" do
      @doc.xml = @xml
      @doc.xml_to_hash.class.should == Hash
    end
    
    it "should normally not raise an exception" do
      @doc.hashed = Hash.from_xml(@xml)
      lambda {@doc.check_for_kb_errors}.should_not raise_error(RetrievalFailure)
    end   
    
    it "should raise an exception for kb errors" do
      @doc.hashed = Hash.from_xml(@xml_error)
      lambda {@doc.check_for_kb_errors}.should raise_error(RetrievalFailure)
    end

  end
  
  describe 'transforming xml to html' do
    
    it "should work" do
      @doc.transform_xml_to_html.should match(/<h2>Oncourse CL training and support/)
    end

    it "should make kb links point to '/helptool/docs/:docid'" do
      @doc.transform_xml_to_html.should match(Regexp.new(%{<a href="/helptool/docs/aitz}))      
    end
    
  end
end

