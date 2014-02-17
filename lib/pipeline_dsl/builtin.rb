module PipelineDsl

    module CountReducer
        def unit
            Hash.new(0)
        end
        def reducer(acc, rec)
            acc[rec] += 1
            acc
        end
    end

    class WordCount < PipelineDsl::Command
        include CountReducer

        def mapper line
            line.chomp.split(/\s/).to_a
        end
        def writer(enum)
            enum.map {|word, val|
                "#{word}\t#{val}"
            }
        end
    end

    class Grep < PipelineDsl::Command
        include PipelineDsl::SimpleMapper

        def initialize(re)
            @re = re
        end

        def mapper(line)
            @re.match(line) ? [ line ] : []
        end
    end
end
