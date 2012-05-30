require 'spec_helper'

module TestOutside1
  recess_group :something do
    def self.test_class_method
      "class_level"
    end
    
    def test_instance_method
      "instance_level"
    end
  end
  
  recess_group :else do
    def self.other_test_class_method
      "class_level2"
    end
    
    def other_test_instance_method
      "instance_level2"
    end
  end
end

class TestOutsideExample1
  outside TestOutside1, :something
end

describe "Outside methods" do
  it "should inject those methods" do
    TestOutsideExample1.test_class_method.should == "class_level"
    TestOutsideExample1.new.test_instance_method.should == "instance_level"
    
    lambda { TestOutsideExample1.other_test_class_method }.should raise_error
  end
end
