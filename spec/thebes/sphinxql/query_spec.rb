require 'spec_helper'

describe Thebes::Query, "against live data" do

  before {
    Thebes::Sphinxql::Client.servers = [
      { :host => '127.0.0.1', :port => 9334 }
    ]
    Item.create \
      :name => "Larry",
      :active => true,
      :body => "Fine was born to a Jewish family as Louis Feinberg[1] in Philadelphia, Pennsylvania, at the corner of 3rd and South Streets. The building there is now a restaurant which is called Jon's Bar & Grill."
    Item.create \
      :name => "Moe",
      :active => true,
      :body => "Moses Horwitz was born in Brooklyn, New York, neighborhood of Brownsville, to Solomon Horwitz and Jennie Gorovitz. He was the fourth of the five Horwitz brothers and of Levite and Lithuanian Jewish ancestry."
    Item.create \
      :name => "Curly",
      :active => false,
      :body => "Curly Howard was born Jerome Lester Horwitz in Brownsville, a section of Brooklyn, New York. He was the fifth of the five Horwitz brothers and of Lithuanian Jewish ancestry."
    Item.create \
      :name => "Shemp",
      :active => true,
      :body => "Shemp, like his brothers Moe and Curly, was born in Brownsville, Brooklyn. He was the third of the five Horwitz brothers and of Levite[citation needed] and Lithuanian Jewish ancestry."
    SPHINX.index # :verbose => true
  }

  context "searching for 'Horwitz'" do

    before {
      @result = Thebes::Sphinxql::Query.run "SELECT * FROM items WHERE MATCH('Horwitz')"
    }

    subject { @result.collect {|r| r } }

    its(:length) { should == 3 }
    its(:first) { subject['_id'] == 2 }
    its(:last) { subject['_id'] == 4 }

  end

  context "searching for 'Horwitz' with filter" do

    before {
      @result = Thebes::Sphinxql::Query.run "SELECT * FROM items WHERE MATCH('Horwitz') AND active = 1"
    }

    subject { @result.collect {|r| r } }

    its(:length) { should == 2 }
    its(:first) { subject['_id'] == 2 }
    its(:last) { subject['_id'] == 4 }

  end


end
