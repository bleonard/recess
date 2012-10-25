require 'spec_helper'

class TestRules1 < Recess::Game::Rules
  rule :must_have_one
  rule :other_one
  rule "third"
end

class TestRules2 < Recess::Game::Rules
  rule :extra2
end

class TestGame1 < Recess::Game::Base
  rules "TestRules2"
  
  def extra2
    "yes"
  end
end

class TestGame2 < Recess::Game::Base
  rules TestRules2
  
  def extra2_not_here
    "no"
  end
end

class TestGame3 < Recess::Game::Base
  rules TestRules1
  rules "TestRules2"
  
  def must_have_one
    
  end
  
  def other_one
    
  end
  
  def third
    "333"
  end
  
  def extra2
    "other"
  end
end

class TestGame4 < Recess::Game::Base
  rules TestRules1
  rules TestRules2
  
  def must_have_one
    
  end
  
  def missing_several
    
  end
end

class TestGameObject1
  game_with TestRules1
  game_with TestRules2
  
  def recess_games
    {"TestRules2" => "TestGame1", "TestRules1" => TestGame3}
  end
end

describe "Rules" do
  it "should list out the methods" do
    TestRules1.list.should =~ [:must_have_one, :other_one, :third]
  end
end

describe "Games" do
  describe "following rules" do
    it "should raise if it doesn't implement all methods" do
      lambda { 
        TestGame1.follow_rules!
      }.should_not raise_error
      
      lambda {
        TestGame2.follow_rules!
      }.should raise_error
      
      lambda { 
        TestGame3.follow_rules!
      }.should_not raise_error
      
      lambda { 
        TestGame4.follow_rules!
      }.should raise_error
    end
    
    it "should get a list of rules it doesn't follow" do
      TestGame1.broken_rules.should == []
      TestGame2.broken_rules.should =~ [:extra2]
      TestGame3.broken_rules.should == []
      TestGame4.broken_rules.should =~ [:other_one, :third, :extra2]
    end
  end  
end

describe "Containers" do
  it "should delegate to the implementation" do
    obj = TestGameObject1.new
    obj.respond_to?(:extra2).should == true
    obj.extra2.should == "yes"
    obj.third.should == "333"
    
    obj.recess_reset_games
    obj.stub(:recess_games).and_return({"TestRules2" => TestGame3})
    obj.extra2.should == "other"
  end
  
  it "should raise if it's not there" do
    obj = TestGameObject1.new
    obj.stub(:recess_games).and_return({})
    lambda {
      obj.extra2
    }.should raise_error
  end
  
  it "should use the same instances if possible" do
    obj = TestGameObject1.new
    obj.stub(:recess_games).and_return({"TestRules2" => "TestGame3", "TestRules1" => TestGame3})
    obj.extra2.should == "other"
    obj.third.should == "333"
    
    instance1 = obj.recess_rules_game_object_mapping("TestRules1")
    instance2 = obj.recess_rules_game_object_mapping("TestRules2")
    
    instance1.extra2.should == "other"
    instance1.third.should == "333"
    instance2.extra2.should == "other"
    instance2.third.should == "333"
    
    instance1.object_id.should == instance2.object_id
  end
  
end
