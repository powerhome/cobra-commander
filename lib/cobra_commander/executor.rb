# frozen_string_literal: true

require_relative "executor/component_exec"
require_relative "executor/multi_exec"

module CobraCommander
  # Execute commands on all components of a ComponentTree
  module Executor
    def self.exec(components, command, output = $stdout, status_output = $stderr)
      components = Array(components)
      exec = if components.size == 1
               ComponentExec.new(components.first)
             else
               MultiExec.new(components)
             end
      exec.run(command, output: output, spin_output: status_output)
    end
  end
end
