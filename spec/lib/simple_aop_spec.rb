require File.expand_path(File.dirname(__FILE__) + '/../../lib/simple_aop')

describe SimpleAOP do 

  context "setting callbacks" do 
    
    before(:each) do
      @aop = AOPClass.new
    end
      
    it "should create ad hoc filters for other methods" do 
      @aop.should_receive(:other_before_filter).once.ordered
      @aop.should_receive(:other_after_filter).once.ordered
      @aop.other_method
    end
      
    it "should create around filters" do
      @aop.should_receive(:before_around).once.ordered
      @aop.should_receive(:middle).once.ordered
      @aop.should_receive(:after_around).once.ordered
      @aop.other_method
    end
      
    it "should take an array for around filters" do 
      @aop.should_receive(:before_around).once.ordered
      @aop.should_receive(:middle).once.ordered
      @aop.should_receive(:after_around).once.ordered
      @aop.test_one
      
      @aop.should_receive(:before_around).once.ordered
      @aop.should_receive(:middle).once.ordered
      @aop.should_receive(:after_around).once.ordered
      @aop.test_two
    end
      
    it "should take an array of methods for a before filter" do
      @aop.should_receive(:before_filter)
      @aop.test_one
    
      @aop.should_receive(:before_filter)
      @aop.test_two
      @aop.should_receive(:before_filter)
      @aop.test_three
    end
      
    it "should take an array of methods for an after filter" do 
      @aop.should_receive(:after_filter)
      @aop.test_one
    
      @aop.should_receive(:after_filter)
      @aop.test_two
    
      @aop.should_receive(:after_filter)
      @aop.test_three
    end 
    
    it "should fire before, after and around filters in the correct order for the same method" do

      @aop.should_receive(:all_for_one).once.ordered
      @aop.should_receive(:before_around).once.ordered
      @aop.should_receive(:middle).once.ordered
      @aop.should_receive(:after_around).once.ordered  
      @aop.should_receive(:all_for_two).once.ordered      

      @aop.test_all.should == "local test value"
    end
    
    it "should maintain the binding context of the original method when used with any/all filters" do
      @aop.should_receive(:test_one).once.ordered
      @aop.should_receive(:test_two).once.ordered
      @aop.test_binding.should == "local test value"
    end
    
    it "should execute any block given to a filtered method with a yield" do
      @aop.should_receive(:test_one)
      @aop.yield_method do 
        "test"
      end.should == "test"
    end
    
    it "should pass the correct arguments to the filtered method" do 
      @aop.with_args({:fu => :bar}).should == {:fu => :bar}
      # with different arity
      @aop.with_args_array(1,2,3,4).should == [1,2,3,4]
      # and a default value
      @aop.with_default_arg("fu").should == "fu bar"
    end
    
    it "should handle multiple before and after filters" do 
      @aop.should_receive(:test_one).once.ordered
      @aop.should_receive(:test_two).once.ordered
      @aop.should_receive(:test_three).once.ordered
      @aop.should_receive(:test_four).once.ordered
      @aop.should_receive(:test_five).once.ordered
      @aop.lots_o_filters
    end
    
    it "should handle multiple around filters" do
      @aop.should_receive(:before_around_one).once.ordered
      @aop.should_receive(:before_around_two).once.ordered
      @aop.should_receive(:middle).once.ordered
      @aop.should_receive(:after_around_two).once.ordered
      @aop.should_receive(:after_around_one).once.ordered
      
      @aop.multiple_around
    end
    
    it "should be able to call super in the context of a before filter" do
      TestBase.should_receive(:test_class_method)
      @aop.test_super
    end
    
  end
end
class TestBase
  def self.test_class_method; end
  
  def test_super
    TestBase.test_class_method
  end
end

class AOPClass < TestBase
  include SimpleAOP
  
  before :test_super, :test_super_filter
  
  before :other_method, :other_before_filter
  after :other_method, :other_after_filter
  
  around :multiple_around, :around_one
  around :multiple_around, :around_two
  
  before [:test_one, :test_two, :test_three], :before_filter
  
  after [:test_one, :test_two, :test_three], :after_filter
  
  around :other_method, :around_filter
  
  around [:test_one, :test_two], :around_filter
  
  around :with_args, :args_around_filter
  
  before :test_binding, :test_one
  after :test_binding, :test_two
  around :test_binding, :around_filter
  
  before :test_all, :all_for_one
  after :test_all, :all_for_two
  around :test_all, :around_filter
  
  before :yield_method, :test_one
  before :with_default_arg, :test_one
  after :with_args_array, :test_two
  
  before :lots_o_filters, :test_one
  before :lots_o_filters, :test_two
  before :lots_o_filters, :test_three
  after :lots_o_filters, :test_four
  after :lots_o_filters, :test_five
  
  def test_super
    super
  end
  
  def test_super_filter
  end
  
  def initialize
    @local_value = "local test value"
  end
  
  attr_accessor :local_value
  
  def multiple_around
    middle
  end
  
  def around_one
    before_around_one
    yield
    after_around_one
  end
  
  def around_two
    before_around_two
    yield
    after_around_two
  end
  
  def yield_method
    yield
  end
  
  def test_binding
    local_value
  end
  
  def with_args_array(*args)
    args
  end
  
  def with_default_arg(fu, bar="bar")
    "#{fu} #{bar}"
  end
  
  def with_args(hash)
    hash
  end
  
  def args_around_filter
    yield
  end
  
  def test_all; middle;  return @local_value; end
  
  def around_filter
    before_around
    value = yield if block_given?
    after_around
    value
  end
  
  def before_around; end
  def after_around; end
  def before_around_one; end
  def after_around_one; end
  def before_around_two; end
  def after_around_two; end
  def all_for_one; end
  def all_for_two; end
  def test_one
    middle
  end
  def middle; end
  def test_two
    middle
  end
  
  def test_three;end
  def other_method
    middle
  end
  def test_four; end
  def test_five; end
  def other_before_filter;end
  def other_after_filter;end
  
  def lots_o_filters; end
  
  def before_filter;end
  def after_filter;end
  
end
