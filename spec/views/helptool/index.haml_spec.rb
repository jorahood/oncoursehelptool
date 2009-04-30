require File.dirname(__FILE__) + '/../../spec_helper'

describe "/helptool/index" do
  
  # when this go! method is defined outside the describe block, the view test finds the go!
  # method in the helptool_controller_spec file before this one.

  def go!
    assigns[:contents] = @contents
    assigns[:search] = @search
    assigns[:doc] = @doc
    render 'helptool/index'
  end

  before(:each) do
    @contents = mock(ContentsDoc, :html => nil)
    @search = mock(KbSearch, :query => nil, :results_list => nil, :noexist_terms => nil)
  end

  it "should have a remote form for the search box" do
    pending 'move this to selenium'
    go!
    response.should have_tag('form#search[onsubmit^=new Ajax.Updater]')
  end

  it 'should update the "results" div' do
    pending 'move this to selenium'
    go!
    response.should have_tag("form#search[onsubmit*='results']")
  end
    
  it "should have a non-ajax fallback action for the search box to index" do
    pending 'move this to selenium'
    go!
    response.should have_tag("form#search[action=#{template.url_for(:action=>'index')}]")
  end
  
  describe "search query submitted" do

    it "should populate search box with existing query term(s)" do
      params[:query] = 'bananas and nuts'
      go!
      response.should have_tag('input[value=?]', 'bananas and nuts')
    end

    it "should render the _result_doc partial when there are docs to display" do
      results_list = [{'title'=>'blah', 'docid'=>'blah'}]
      @search.should_receive(:results_list).twice.and_return(results_list)
      template.expect_render(:partial => 'result_doc', :collection => results_list)
      go!
    end

    it 'should assign a class of kblink to all result links' do
      results_list = [{'title'=>'blah', 'docid'=>'blah'}]
      @search.stub!(:results_list).and_return(results_list)
      go!
      response.should have_tag('a.kblink')
    end
    
    it 'should not display ul#doc_list when no docs to display' do
      go!
      response.should_not have_tag('ul#doc_list')    
    end
    
    it 'should display div#noexist when there are noexist terms' do
      noexist = ['bananas','nuts']
      @search.should_receive(:noexist_terms).twice.and_return(noexist)
      go!
      response.should have_tag('span.noexist', noexist.to_sentence)
    end
  end
  
  describe 'doc requested' do
    
    it "should display div#doc_text" do
      @doc = mock(KbDoc)
      @doc.should_receive(:html).and_return('hiya')
      go!
      response.should have_tag('div#doc_text', 'hiya')
    end
    
  end

end


