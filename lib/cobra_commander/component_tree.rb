# frozen_string_literal: true

require "json"
require "ostruct"

module CobraCommander
  # Representation of the tree of components and their dependencies
  class ComponentTree
    def initialize(path)
      @root_path = path
    end

    def to_h
      TreeGenerator.new(UMBRELLA_APP_NAME, @root_path).to_h
    end

    # Generates component tree
    class TreeGenerator
      def initialize(name, path, ancestry = Set.new)
        @name = name
        @root_path = path
        @ancestry = ancestry
        @type = type_of_component
      end

      def to_h
        {
          name: @name,
          path: @root_path,
          type: @type,
          ancestry: @ancestry,
          dependencies: dependencies.map(&method(:dep_representation)),
        }
      end

    private

      def type_of_component
        return "Ruby & JS" if gem? && node?
        return "Ruby" if gem?
        return "JS" if node?
      end

      def dependencies
        @deps ||= begin
          deps = ruby_dependencies + js_dependencies
          deps.sort_by(&:name)
        end
      end

      def ruby_dependencies
        @ruby_dependencies ||= begin
          return [] unless gem?
          bundler_definition.dependencies.select do |dep|
            dep.source&.is_a_path? && dep.source.path.to_s != "."
          end
        end
      end

      def js_dependencies
        @nodes ||= begin
          return [] unless node?
          json = JSON.parse(File.read(package_json_path))
          js_format(json["dependencies"])
        end
      end

      def js_format(deps)
        return [] if deps.nil?
        linked_deps = deps.select { |_, v| v.start_with? "link:" }
        linked_deps.map do |_, v|
          relational_path = v.split("link:")[1]
          dep_name = relational_path.split("/")[-1]
          OpenStruct.new(name: dep_name, path: relational_path)
        end
      end

      def bundler_definition
        ::Bundler::Definition.build(gemfile_path, gemfile_lock_path, nil)
      end

      def gem?
        @gem ||= File.exist?(gemfile_path)
      end

      def node?
        @node ||= File.exist?(package_json_path)
      end

      def package_json_path
        File.join(@root_path, "package.json")
      end

      def gemfile_path
        File.join(@root_path, "Gemfile")
      end

      def gemfile_lock_path
        File.join(@root_path, "Gemfile.lock")
      end

      def dep_representation(dep)
        dep_path, dep_name = extract_dep_info(dep)
        ancestry = @ancestry + [{ name: @name, path: @root_path, type: @type }]
        self.class.new(dep_name, dep_path, ancestry).to_h
      end

      def extract_dep_info(dep)
        relational_path = dep.is_a?(OpenStruct) ? dep.path : "#{dep.source.path}/#{dep.name}"
        path = File.expand_path(File.join(@root_path, relational_path))
        [path, dep.name]
      end
    end
  end
end
