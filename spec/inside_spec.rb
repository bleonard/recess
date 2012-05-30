require 'spec_helper'

class TestInside1 < Recess::Inside::Base
  parent_instance :foo
  parent_instance :foo=
  
  def my_method
    "yes: #{foo}"
  end
  
  def other_method
    "no"
  end
end

class TestInside2 < Recess::Inside::Base
  alias_parent_instance :super_foo, :foo
  
  def foo
    "super: #{super_foo}"
  end
end

class TestContainer1
  inside TestInside1, :my_method
  
  def initialize(val)
    @val = val
  end
  
  def foo
    @val
  end
end

class TestContainer2
  inside TestInside1, :my_method, :data => :whatever
  
  def initialize(val)
    @val = val
  end
  
  def foo
    @val
  end
  
  def whatever
    @whatever ||= TestExample1Data.new
  end
end

class TestContainer3
  # can't put it before as it prevents aliasing
  
  def foo
    "container"
  end
  
  # override, but call back to the above
  inside TestInside2, :foo
end


class TestInside4 < Recess::Inside::Base
  
  def self.insided(model)
    model.callback_here("yeah")
  end
  
  def foo
    "here"
  end
end

class TestContainer4
  def self.callback_here(val)
    @called_value = val
  end
  
  def self.called_value
    @called_value
  end
  
  inside TestInside4, :foo
end

class TestExample1Data
  def initialize(val="data")
    @val = val
  end
  def foo
    @val
  end
end

class TestExample1
  def foo=val
    @foo = val
  end
  def foo
    @foo ||= "one"
  end
  
  def bar
    "two"
  end
  
  def data
    @data ||= TestExample1Data.new
  end
  
  def initd(val)
    @initd ||= TestExample1Data.new(val)
  end
end

describe "Containers" do
  it "should know what properties are requested of it" do
    TestContainer1.recess_inside_instance_methods.should =~ ["foo", "foo="]
    TestContainer1.recess_inside_instance_methods(TestInside1).should =~ ["foo", "foo="]
    TestContainer3.recess_inside_instance_methods(TestInside2).should =~ ["foo"]
  end
  
  it "should allow call through to super" do
    container = TestContainer3.new
    container.foo.should == "super: container"
  end
  
  it "should pass through to the inside" do
    container = TestContainer1.new("what")
    container.foo.should == "what"
    container.my_method.should == "yes: what"
    
    lambda { container.other_method }.should raise_error
  end
  
  it "should be able to take in data attribute" do
    container = TestContainer2.new("what")
    container.foo.should == "what"
    container.whatever.foo.should == "data"
    container.my_method.should == "yes: data"
    
    lambda { container.other_method }.should raise_error
  end
  
  it "should call back the container when included" do
    TestContainer4.called_value.should == "yeah"
  end
end

describe "Base" do
  it "should pass through declared attribtues to the init'd class" do
    example = TestExample1.new
    test = TestInside1.new(example)
    test.foo.should == "one"
    test.foo = "set"
    test.foo.should == "set"
    
    lambda { test.bar }.should raise_error
  end
  
  it "should use the data if noted" do
    example = TestExample1.new
    test = TestInside1.new(example, :data)
    test.foo.should == "data"
    
    example = TestExample1.new
    test = TestInside1.new(example, [:data])
    test.foo.should == "data"
  end
  
  it "should use the data and args" do
    example = TestExample1.new
    test = TestInside1.new(example, [:initd, "sent"])
    test.foo.should == "sent"
  end
  
  it "should call through to the parent" do
    example = TestExample1.new
    test = TestInside2.new(example)
    test.foo.should == "super: one"
  end
end
