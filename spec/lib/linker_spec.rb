require File.expand_path(File.dirname(__FILE__) + '/../../lib/linker')

describe Array do 
  it 'should add a new object to an empty Array' do
    ary = []
    ary.add_and_link(:one).should == [:one]
  end
  
  it 'should link a new object in an array with existing symbols' do
    ary = [:one]
    ary.add_and_link(:two).should == [:one, :two]
    ary[0].next.should == :two
  end
  
  it 'should convert strings to symbols' do
    ary = ['one']
    ary.add_and_link('two').should == [:one, :two]
    ary[0].next.should == :two
  end
  
  it 'should add arrays as well as single objects' do
    ary = [:one]
    ary.add_and_link([:two, :three, :four]).should == [:one, :two, :three, :four]
    ary.first.next.should == :two
    ary[1].next.should == :three
    ary[2].next.should == :four
    ary[3].next.should == nil
  end
  
  it 'should link many objects' do 
    ary = [:one]
    ary.add_and_link(:two).should == [:one, :two]
    ary[0].next.should == :two
    
    ary.add_and_link(:three).should == [:one, :two, :three]
    ary[1].next.should == :three
    
    ary.add_and_link(:four).should == [:one, :two, :three, :four]
    ary[2].next.should == :four
    
    ary.add_and_link(:five).should == [:one, :two, :three, :four, :five]
    ary[3].next.should == :five
    
    ary[4].next.should == nil
  end
end
