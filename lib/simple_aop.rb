
module SimpleAOP

  def self.included(klass)
    klass.extend ClassMethods
    klass.initialize_included_features
  end
  
  module ClassMethods
    
    def initialize_included_features
      @callbacks = Hash.new
      @callbacks[:before] = Hash.new{|h,k| h[k] = []}
      @callbacks[:after] = @callbacks[:before].clone
      @callbacks[:around] = {}
      
      class << self
        attr_accessor :callbacks
      end
    end

    def method_added(method)
      redefine_method(method) if is_a_callback?(method)
    end

    def is_a_callback?(method)
      registered_methods.include?(method)
    end

    def registered_methods
      callbacks.values.map(&:keys).flatten.uniq
    end

    def store_callbacks(type, method_name, *callback_methods)
      callbacks[type.to_sym][method_name.to_sym] += callback_methods.flatten.map(&:to_sym)
    end

    def process_callback_set(type, original_method, *callbacks)
      if original_method.kind_of?(Array)
        original_method.each {|method| store_callbacks(type, method, *callbacks) }
      else
        store_callbacks(type, original_method, *callbacks)
      end
    end
    
    def before(original_method, *callbacks)
      process_callback_set(:before, original_method, *callbacks)
    end

    def after(original_method, *callbacks)
      process_callback_set(:after, original_method, *callbacks)
    end
    
    def around(original_method, callback)
      if original_method.kind_of?(Array)
        original_method.each {|method| callbacks[:around][method.to_sym] = callback.to_sym }
      else
        callbacks[:around][original_method.to_sym] = callback.to_sym
      end
    end

    def objectify_and_remove_method(method)
      if method_defined?(method.to_sym)
        original = instance_method(method.to_sym)
        remove_method(method.to_sym)
        original
      else
        nil
      end
    end

    def redefine_method(original_method)
      original = objectify_and_remove_method(original_method)
      mod = Module.new
      mod.class_eval do
        define_method(original_method.to_sym) do |*args, &block|
          trigger_callbacks(original_method, :before)
          return_value = trigger_around_callback(original_method) do
            original.bind(self).call(*args, &block) if original
          end
          trigger_callbacks(original_method, :after)
          return_value
        end
      end
      include mod
    end
  end
  
  def trigger_callbacks(method_name, callback_type) 
    self.class.callbacks[callback_type][method_name.to_sym].each{|callback| send callback}
  end

  def trigger_around_callback(method_name, &block)
    callback = self.class.callbacks[:around][method_name.to_sym]
    if callback && callback != []
      return send(callback) { block.call }
    else
      return yield
    end
  end
 
end


