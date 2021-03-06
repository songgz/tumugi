require 'graphviz'
require 'tmpdir'
require 'fileutils'
require 'tumugi/mixin/listable'

module Tumugi
  module Command
    class Show
      include Tumugi::Mixin::Listable

      @@supported_formats = ['dot', 'png', 'jpg', 'svg', 'pdf']

      def execute(dag, options={})
        out = options[:out]
        if out
          ext = File.extname(options[:out])
          format = ext[1..-1] if ext.start_with?('.')
          raise "#{format} is not supported format" unless @@supported_formats.include?(format)
        else
          format = options[:format]
        end

        g = GraphViz.new(:G, type: :digraph, rankdir: "RL")
        tasks = dag.tsort
        tasks.each do |task|
          g.add_nodes(task.id.to_s)
        end
        tasks.each do |task|
          list(task._requires).each do |req|
            g.add_edge(g.get_node(req.id.to_s), g.get_node(task.id.to_s))
          end
        end

        if out
          logger.info "output result to #{out}"
          FileUtils.mkdir_p(File.dirname(out))
          if format == 'dot'
            File.write(out, g.to_s)
          else
            g.output(format => out)
          end
        else
          print g
        end

        return true
      end

      def logger
        @logger ||= Tumugi::ScopedLogger.new("tumugi-show")
      end
    end
  end
end
