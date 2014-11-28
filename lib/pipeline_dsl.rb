require "pipeline_dsl/version"
require "pipeline_dsl/base"
require "pipeline_dsl/concrete_pipe"
require "pipeline_dsl/buffer_strategy"
require "pipeline_dsl/builtin"

module PipelineDsl

    def cat(input, &block)
        dest = block[]
        if dest
            out = PipelineDsl::build(dest) | STDOUT
            out.puts(input)
        end
    end

    def multi(*dests)
        ConcretePipe::Split.new(dests)
    end

    def grep(re)
        Grep.new(re)
    end

    def partition(ok_case, ng_case, &pred)
        ConcretePipe::Partition.new(ok_case, ng_case, &pred)
    end

    module_function :cat
    module_function :multi
    module_function :grep

end
