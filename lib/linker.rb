
# allow Symbols to link with 'next' interface
class Symbol
  attr_accessor :next
end

# Adds an interface to Array to allow adding and linking symbols incrementally
# Behaves like '+', i.e.: [1,2].add_and_link([3,4]) -> [1,2,3,4]
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


