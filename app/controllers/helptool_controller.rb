class HelptoolController < ApplicationController

  def search
    @search = params[:query] ? KbSearch.new(params[:query]) : KbSearch.new
    @search.retrieve_results
    @query = @search.query
    if request.xhr?
      #params[:format] catches my spec that sets the header to xml, but I can't get it to work with my YUI client
      if params[:livequery] or params[:format] == 'xml'
        render :xml=> @search.xml
      else
        render :partial=> 'results'
      end
      #      respond_to do |format|
      #        format.xml {render :xml=> @search.xml}
      #        format.html {render :partial=> 'results'}
      #      end
    else
      contents
      render :action=> 'index'
    end
  end

  def docs
    if params[:docid]
      @doc = KbDoc.new(params[:docid])
      @doc.retrieve_text
      if request.xhr?
        render :text=> @doc.html
      else
        contents
        render :action=> 'index'
      end
    end
  end
  
  def contents
    @contents = ContentsDoc.new
    @contents.retrieve_text
  end

  def index
    contents
  end
  
end
