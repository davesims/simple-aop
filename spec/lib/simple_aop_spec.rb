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
    
  end
end

class AOPClass 
  include SimpleAOP
  
  before :other_method, :other_before_filter
  after :other_method, :other_after_filter
  
  before [:test_one, :test_two, :test_three], :before_filter
  
  after [:test_one, :test_two, :test_three], :after_filter
  
  around :other_method, :around_filter
  
  around [:test_one, :test_two], :around_filter
  
  around :with_args, :args_around_filter
  
  def with_args(hash)
  end
  
  def args_around_filter
    yield
  end
  
  def around_filter
    before_around
    yield if block_given?
    after_around
  end
  
  def before_around; end
  def after_around; end
  
  def test_one
    middle
  end
  def middle; end
  def test_two
    middle
  end
  
  def test_three;end
  def other_method;end
  def other_before_filter;end
  def other_after_filter;end
  def not_an_adapter;end
  
  def create;end
  def update;end
  
  def query;end
  def delete;end
  
  def before_filter;end
  def after_filter;end
  
end
