require 'spec_helper'

describe Newegg::Api do
  before(:each) do
    FakeWeb.clean_registry
  end
  
end #end Newegg::Api

describe Newegg::Navigation do
  before(:each) do
    FakeWeb.clean_registry
  end

  it %q{returns success for retrieve(store_id, category_id, node_id)} do
    navigation = Newegg::Navigation.new
    response = {"Description"=> "Backup Devices & Media", "CategoryType"=> 0, "CategoryID"=> 2, "StoreID"=> 1, "ShowSeeAllDeals"=> true, "NodeId"=> 6642}
    navigation.send(:retrieve, response["StoreID"], response["CategoryID"], response["NodeId"]).status.to_i.should == 200
  end
end #end Newegg::Navigation

describe Newegg::Search do
  before(:each) do
    FakeWeb.clean_registry
  end

  it %q{returns success for retrieve(store_id, category_id, sub_category_id, node_id)} do
    response ={"Description"=> "Computer Cases", "CategoryType"=> 1, "CategoryID"=> 7, "StoreID"=> 1, "ShowSeeAllDeals"=> false, "NodeId"=> 7583}
    search = Newegg::Search.new
    search.send(:retrieve, response["StoreID"], response["CategoryType"], response["CategoryID"], response["NodeId"], 1).status.to_i.should == 200
  end

  it %q{throws error for search(store_id, category_id, sub_category_id, node_id} do
    FakeWeb.register_uri(:post, %r{http://www.ows.newegg.com/Search.egg/Advanced}, :status => ["404","Not Found"])
    response = {"Description"=> "Computer Cases", "CategoryType"=> 1, "CategoryID"=> 7, "StoreID"=> 1, "ShowSeeAllDeals"=> false, "NodeId"=> 7583}
    search = Newegg::Search.new
    lambda {
     search.send(:retrieve, response["StoreID"], response["CategoryType"], response["CategoryID"], response["NodeId"], 1)
    }.should raise_error Newegg::NeweggClientError
  end
  
  it %q{throws error for search(store_id, category_id, sub_category_id, node_id} do
    FakeWeb.register_uri(:post, %r{http://www.ows.newegg.com/Search.egg/Advanced}, :status => ["500","Server"])
    response = {"Description"=> "Computer Cases", "CategoryType"=> 1, "CategoryID"=> 7, "StoreID"=> 1, "ShowSeeAllDeals"=> false, "NodeId"=> 7583}
    search = Newegg::Search.new
    lambda {
     search.send(:retrieve, response["StoreID"], response["CategoryType"], response["CategoryID"], response["NodeId"], 1)
    }.should raise_error Newegg::NeweggServerError
  end
end #end Newegg::Search
