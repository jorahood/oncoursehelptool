require File.dirname(__FILE__) + '/../spec_helper'

require 'hpricot'
require 'yaml'
include Exceptions

describe KbSearch do
  
  before(:each) do
    @results_xml = File.read("#{FIXTURES}/search_results.xml")
    @error_xml = File.read("#{FIXTURES}/search_error.xml")
    @hashed = 
      YAML.load_file("#{FIXTURES}/search_results_hash.yml")['kbsearch']
    @one_result_hash = 
      YAML.load_file("#{FIXTURES}/one_search_result_hash.yml")['kbsearch']
    @no_results_hash = 
      YAML.load_file("#{FIXTURES}/chunky_bacon_search_results.yml")['kbsearch']
    @query = 'blah'
    @search = KbSearch.new(@query)
    @no_query_search = KbSearch.new()
  end

  it "should have a query attribute" do
    @search.query.should == @query
  end
  
  it "should create an blank query if none supplied" do
    @no_query_search.query.should == ''
  end
  
  it "should escape &s" do
    query = "&&&"
    search = KbSearch.new(query)
    search.escaped_query.should == '%26%26%26'
  end

  describe 'retrieving results' do

    it "should request xml" do
      @search.request_xml.should match(/<kbsearch>/)
    end
      
    it "should be able to make multiple word queries" do
      query = 'assignment student class'
      search = KbSearch.new(query)
      search.request_xml.should match(/<query>'assignment', and 'student', and 'class'/)
    end    

    it "should not normally raise an exception" do
      @search.stub!(:hashed).and_return(Hash.from_xml(@results_xml))
      lambda {@search.check_for_kb_errors}.should_not raise_error(RetrievalFailure)
    end
    
    it "should raise an exception for search errors" do
      @search.stub!(:hashed).and_return(Hash.from_xml(@error_xml))
      lambda {@search.check_for_kb_errors}.should raise_error(RetrievalFailure)
    end  

    it "self.retrieve_results should do everything required" do
      @search.should_receive(:check_for_kb_errors)
      @search.should_receive(:process_results)
      @search.should_receive(:check_for_noexist_terms)
      @search.retrieve_results
    end
  end

  describe "processing results" do

    it "should create a hash" do
      @search.stub!(:xml).and_return(@results_xml)
      @search.xml_to_hash.keys.should include("kbsearch")
    end

    it "should open the kbsearch hash before saving to #hashed" do
      @search.stub!(:hashed).and_return(@hashed)
    end
    
    it "should transform results hash to an array" do
      @search.stub!(:hashed).and_return(@hashed)
      @search.extract_array_from_hash.class.should == Array
    end

    it "should create an array even for one result" do
      @search.stub!(:results_list).and_return(@one_result_hash['results']['result'])
      @search.ensure_array_for_single_member.should == 
        [@one_result_hash['results']['result']]
    end

    it "should know when there are results" do
      @search.stub!(:hashed).and_return(@hashed)
      @search.results?.should == true
    end

    it "should know when there are no results" do
      @search.stub!(:hashed).and_return(@no_results_hash)
      @search.results?.should == false
    end
    
    describe "for failed searches" do

      before do
        @bad_query = 'chunky bacon'
        @bad_search = KbSearch.new(@bad_query)
        @bad_search.hashed = @no_results_hash
      end
    
      it "should have an array of noexist terms if there were any" do
        @bad_search.check_for_noexist_terms.should == @bad_query.split.sort
      end
    
      it "#results_list should return nil" do
        @bad_search.extract_array_from_hash.should == nil
      end
      
    end
    
  end
end
