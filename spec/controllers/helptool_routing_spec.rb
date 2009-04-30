require File.dirname(__FILE__) + '/../spec_helper'

describe HelptoolController do

  describe "route generation" do

    it "should map {:controller=>helptool, :action=>index} to /" do
      route_for(:controller => "helptool", :action => "index").should == "/"
    end
    
  end

  describe "route recognition" do

    it "should map '' to helptool/index" do
      params_from(:get, "").should == 
        {:controller => "helptool", :action => "index"}
    end

    it "should map helptool/docs/:docid to the docs action" do
      params_from(:get, "/helptool/docs/wxyz").should ==
        {:controller => 'helptool', :action => 'docs', :docid => 'wxyz'}
    end

    it "should map helptool/live_search to search action with :format=xml" do
      params_from(:get, "/helptool/live_search").should ==
        {:controller=> 'helptool', :action=> 'search', :format=> 'xml'}
    end
    it "should map helptool/search to search action with :format=html" do
      params_from(:get, "/helptool/search").should ==
        {:controller=> 'helptool', :action=> 'search', :format=> 'html'}
    end    
  end

end