module Recess::Game
  module ClassMethods
    def recess_list_of_games
      @game_with ||= []
    end
    
    def game_with(what, options = {})
      clazz_name = what.to_s
      rules_clazz = Recess::Util.constantize(clazz_name)
      args = rules_clazz.list.clone
      args << options
      send(:inside, clazz_name, *args)
      recess_list_of_games << clazz_name
      
      unless method_defined? :recess_rules_game_object_mapping
        define_method(:recess_rules_game_object_mapping) do |rule|
          key = rule.to_s
          @cached_recess_games ||= self.recess_games
          @recess_rules_game_object_mapping ||= {}

          game_clazz_name = @cached_recess_games[key]
          # TODO: try again if it's not there? always try?
          raise "No game implementation of #{key} given." unless game_clazz_name
          
          game_clazz_name = game_clazz_name.to_s
          game_clazz = Recess::Util.constantize(game_clazz_name)
          @recess_rules_game_object_mapping[key] = nil unless @recess_rules_game_object_mapping[key].is_a? game_clazz
          return @recess_rules_game_object_mapping[key] if @recess_rules_game_object_mapping[key]
          
          # see if we already have this object
          obj = nil
          @cached_recess_games.each do |rule_key, name|
            if name.to_s == game_clazz_name
              obj = @recess_rules_game_object_mapping[rule_key]
              break if obj
            end
          end
          
          unless obj
            data_method = self.class.recess_inside_objects_options[clazz_name][:data]
            obj = game_clazz.new(self, data_method)
          end
          
          @recess_rules_game_object_mapping[key] = obj
        end
      end
      
      unless method_defined? :recess_reset_games
        define_method(:recess_reset_games) do
          @cached_recess_games = nil
          @recess_rules_game_object_mapping = nil
        end
      end
    end
  end
  
  class Rules < Recess::Inside::Base
    def self.rule(method_name)
      list << method_name.to_sym
      
      define_method method_name do |*args|
        raise "there is no parent object" unless parent_root
        game_object = parent_root.recess_rules_game_object_mapping(self.class.name.to_s)
        game_object.send(method_name, *args)
      end
    end
    
    def self.list
      @list ||= []
    end
  end
  
  class Base < Recess::Inside::Base
    def self.rules(clazz)
      list_of_rules << clazz.to_s
    end
    def self.list_of_rules
      @rules ||= []
    end
    
    def self.broken_rules
      out = []
      rule_methods_needed.each do |meth|
        out << meth unless self.method_defined? meth
      end
      out
    end
    
    def self.follow_rules!
      missing = self.broken_rules
      raise "#{self.name} is missing rule method(s): [#{missing.join(", ")}]" unless missing.size == 0
    end
    
    protected
    
    def self.rule_methods_needed
      out = []
      list_of_rules.each do |clazz_name|
        rules_clazz = Recess::Util.constantize(clazz_name.to_s)
        out.concat rules_clazz.list
      end
      out.uniq
    end
    
  end
    
end

Object.send :include, Recess::Game::ClassMethods
