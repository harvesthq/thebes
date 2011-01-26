require 'spec_helper'

describe Thebes::Query, "after configuration" do

  before(:all) {
    Thebes::Query.servers = [['127.0.0.2', 111]]
  }

  subject { Thebes::Query.new }

  its(:servers) { should == [['127.0.0.2', 111]] }

  context "running query" do
    
    before(:each) {
      Thebes::Query.any_instance.stubs(:run)
    }

    after(:each) {
      Thebes::Query.run {|q| }
    }

    it "should run the query on an instance" do
      Thebes::Query.any_instance.expects(:run)
    end

    it "should call the before_query callback" do
      Thebes::Query.before_query = Proc.new {|q| }
      Thebes::Query.before_query.expects(:call)
    end

    it "should call the before_running callback" do
      Thebes::Query.before_running = Proc.new {|q| }
      Thebes::Query.before_running.expects(:call)
    end

  end

end
