require 'spec_helper'

describe Thebes::Sphinxql::Client, "after configuration" do

  before(:all) {
    Thebes::Sphinxql::Client.servers = [
      { :host => 'localhost', :port => 9009 }
    ]
  }

  subject { Thebes::Sphinxql::Client.new }

  its(:servers) { should == [{ :host => "localhost", :port => 9009 }] }

end
