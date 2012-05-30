module Recess::Inside
  module ClassMethods
    def recess_inside_instance_methods(from_base=nil)
      return [] unless @recess_inside_instance_methods
      return @recess_inside_instance_methods.keys unless from_base
      (@recess_inside_base_classes[from_base] || []).uniq
    end
    
    def recess_inside_objects_options
      @recess_inside_objects_options ||= {}
    end
    
    def inside(what, *args)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      object_clazz = what
      recess_inside_objects_options[object_clazz.to_s] = options
      
      @recess_inside_instance_methods ||= {}
      @recess_inside_base_classes ||= {}
      
      unless @recess_inside_base_classes[object_clazz]
        if object_clazz.respond_to?(:insided)
          if object_clazz.method(:insided).arity == 1
            object_clazz.insided(self)
          else
            object_clazz.insided(self, args)
          end
        end
      end
      
      object_clazz.all_parent_instance_methods.each do |used|
        @recess_inside_base_classes[object_clazz] ||= []
        @recess_inside_base_classes[object_clazz] << used
        
        @recess_inside_instance_methods[used] ||= []
        @recess_inside_instance_methods[used] << object_clazz
      end
      
      unless method_defined? :recess_inside_instance_objects
        define_method(:recess_inside_instance_objects) do |clazz|
          data_method = self.class.recess_inside_objects_options[clazz.to_s][:data]
          @recess_inside_instance_objects ||= {}
          @recess_inside_instance_objects[clazz.to_s] ||= clazz.new(self, data_method)
        end
      end

      args.each do |delegated|
        the_alias = object_clazz.parent_aliased_instance_methods[delegated.to_s]
        if the_alias and not method_defined?(the_alias)
          if method_defined?(delegated)
            class_eval("alias #{the_alias} #{delegated}")
          elsif respond_to?(:column_names) # TODO: causing crash on load --- and column_names.include?(delegated.to_s)
            define_method the_alias do
              read_attribute(delegated)
            end
          end
        end
        
        define_method delegated do |*args|
          recess_inside_instance_objects(object_clazz).send(delegated, *args)
        end
      end
    end
  end
  
  class Base
    def self.all_parent_instance_methods
      (parent_instance_methods + parent_aliased_instance_methods.keys).collect(&:to_s).uniq
    end
    
    def self.parent_instance_methods
      @parent_instance_methods ||= []
    end
    
    def self.parent_aliased_instance_methods
      @parent_aliased_instance_methods ||= {}
    end
    
    def self.parent_instance meth
      parent_instance_methods << meth.to_s
      define_method meth do |*args|
        parent_data.send(meth, *args)
      end
    end
    
    def self.alias_parent_instance super_meth, meth
      parent_instance_methods << meth.to_s
      the_alias = "#{meth}_before_recess"
      parent_aliased_instance_methods[meth.to_s] = the_alias
      define_method super_meth do |*args|
        if parent_data.respond_to?(the_alias)
          parent_data.send(the_alias, *args)
        else
          parent_data.send(meth, *args)
        end
      end
    end
    
    def initialize(instance, data_method = nil)
      @instance = instance

      if data_method
        if data_method.is_a? Array
          @data_args = data_method
        else
          @data_args = [data_method]
        end
      else
        @data_args = nil
      end
    end

    protected
    
    def parent_root
      @instance
    end
    
    def data_args
      @data_args
    end
    
    def parent_data
      if data_args
        parent_root.send(*data_args)
      else
        parent_root
      end
    end
  end
end

Object.send :include, Recess::Inside::ClassMethods
