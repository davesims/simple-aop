
# allow Symbols to link with 'next' interface
class Symbol
  attr_accessor :next
end

# Adds an interface to Array to allow adding and linking symbols incrementally
# Behaves like '+' in that it will add a single object, or an array of objects
# where each object in the given array is added individually, rather than adding 
# the array as a single element. 
class Array
  def add_and_link(value)
    Array(value).each do |item|
      if item.respond_to?(:to_sym)
        if self[size-1] 
          self[size-1] = self[size-1].to_sym
          self[size-1].next = item.to_sym
        end
        self << item.to_sym
      end
    end
    self
  end
end


