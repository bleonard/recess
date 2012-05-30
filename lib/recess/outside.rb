module Recess::Outside
  module ClassMethods
    def recess_group(name, &block)
      @recess_groups ||= {}
      @recess_groups[name.to_s] = block
    end
    
    def outside(what, *args)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      object_clazz = what
      
      groups = object_clazz.instance_variable_get("@recess_groups")
      raise "Missing recess_groups directive in #{object_clazz}" unless groups
      
      args.each do |trait_name|
        macro = groups[trait_name.to_s]
        raise "Missing recess group name: #{trait_name}" unless macro
        
        class_exec(&macro)
      end
    end
  end
end

Object.send :include, Recess::Outside::ClassMethods
