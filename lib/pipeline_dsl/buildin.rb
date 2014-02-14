module PipelineDsl

    class WordCount < PipelineDsl::Command
        def mapper line
            line.chomp.split(/\s/).to_a
        end
        def unit
            Hash.new(0)
        end
        def reducer(acc, word)
            acc[word] = acc[word] + 1
            acc
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
