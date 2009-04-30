require File.dirname(__FILE__) + '/../spec_helper'

describe HelptoolController do

  describe "index action" do

    before do
      @fake_contents = mock(ContentsDoc, :retrieve_text=>nil)
      ContentsDoc.stub!(:new).and_return(@fake_contents)      
    end    

    it "should be successful" do
      get :index
      response.should be_success
    end

    it "should render index template" do
      get :index
      response.should render_template('index')
    end
    
    it "should retrieve the contents" do
      controller.should_receive(:contents)
      get :index
    end
  end

  describe "search action" do

    before do
      @search_term = 'schnell'
      @search_params = {'query'=> @search_term}
      @fake_search = mock(KbSearch, :query=>@search_term, :null_object=>true)
      KbSearch.stub!(:new).and_return(@fake_search)
    end
 
    it "should assign a KbSearch instance to @search when query submitted" do
      get :search, @search_params
      assigns[:search].should == @fake_search
    end

    it "should create KbSearch with query=nil if no query submitted" do
      KbSearch.should_receive(:new).with(no_args).and_return(@fake_search)
      get :search
    end

    it "should assign a KbSearch instance when no query submitted" do
      get :search
      assigns[:search].should == @fake_search
    end

    it "should assign the query to @query" do
      get :search, @search_params
      assigns[:query].should == @search_term
    end
    
    it "should retrieve the contents" do
      controller.should_receive(:contents)
      get :search, @search_params
    end

    it "should render the index template" do
      get :search
      response.should render_template('index')
    end

    describe "xhr" do
      
      def search_xhr!(params=nil) 
        xhr :get, :search, params
      end

      it "should render the results partial" do
        search_xhr!(@search_params)
        response.should render_template('_results')
      end
      
      it "should return @search.xml when xml requested (ie HTTP-Accept=text/xml) (for autocomplete widget)" do
        xhr :get, :search, {:format=> 'xml'}, params
        response.headers['type'].should match(/application\/xml/) 
      end
    end
  end
  
  describe "doc action" do

    def get_doc!
      get :docs, {'docid'=> 'atjv'}
    end
  
    before do
      @fake_doc = mock(KbDoc,:retrieve_text=> nil, 
        :docid=> 'atjv', 
        :html=>'blah')
      KbDoc.stub!(:new).and_return(@fake_doc)
      controller.stub!(:contents)
    end
      
    it "should create a KbDoc instance" do
      KbDoc.should_receive(:new).with('atjv').and_return(@fake_doc)
      get_doc!
    end

    it "should assign the retrieved doc to @doc" do
      get_doc!
      assigns[:doc].should == @fake_doc
    end

    it "should retrieve the text for the doc" do
      @fake_doc.should_receive(:retrieve_text)
      get_doc!
    end
    
    it "should retrieve the contents" do
      controller.should_receive(:contents)
      get_doc!
    end
    
    it "should render the index template" do
      get_doc!      
      response.should render_template('index')
    end
    
    describe "xhr" do
      
      def get_doc_xhr!
        xhr :get, :docs, {'docid'=> 'atjv'}        
      end

      it "should respond with just the body rendered as text" do
        get_doc_xhr!
        response.body.should match(/^#{@fake_doc.html}$/)
      end
      
      it "should not retrieve contents" do
        get_doc_xhr!
        assigns[:contents].should == nil
      end
    end
  end

end