require File.dirname(__FILE__) + '/../spec_helper'

include CommonMethods

describe ContentsDoc do

  before do
    @toc = ContentsDoc.new
    @xml = File.read("#{FIXTURES}/contents_doc.xml")
  end
  
  it "should use its special docid" do
    @toc.docid.should == ConfigFile[:contents_docid]
  end
  
  it "should render just the table of contents without the title or footer" do
    @toc.retrieve_text
    @toc.html.should match(/\A<ul>.+<\/ul>\Z/m)
  end

end

