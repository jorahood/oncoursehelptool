require File.dirname(__FILE__) + '/../spec_helper'

include CommonMethods

describe ToolIndexDoc do

  before do
    @index = ToolIndexDoc.new
  end
  
  it "should use its special docid" do
    @index.docid.should == ConfigFile[:tool_index_docid]
  end

  it "should return a docid for a tool name" do
    @index.lookup('sakai.rwiki').should == 'atyc'
  end
  
  it "should return the default doc for a bad tool name"  do
    @index.lookup('blabyblabblab').should == ConfigFile[:default_docid]
  end
end