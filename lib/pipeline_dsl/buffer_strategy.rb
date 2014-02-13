require 'singleton'

module BufferStrategy

    class Strategy
        include Singleton
        def initialize
            @s = Buffer.new
        end
        def proc(enum, pipe)
            @s.proc(enum, pipe)
        end
        def change!(s)
            @s = s if s
        end
    end

    def get
        Strategy.instance
    end

    def set!(type, *opt)
        strategy = BufferStrategy.get
        it = case type
             when :buffer
                 Buffer.new
             when :no_buffer
                 Stream.new
             when :interval
                 Interval.new(*opt)
             end
        strategy.change!(it)
    end
    module_function :set!
    module_function :get

    class Buffer
        def proc(enum, pipe)
            rest = enum.reduce(pipe.unit) {|acc, line|
                pipe.accumulate(acc, line)
            }
            pipe.write(rest)
        end
    end

    class Stream
        def proc(enum, pipe)
            enum.each { |line|
                pipe.write( pipe.accumulate(pipe.unit, line) )
            }
        end
    end

    class Interval
        def initialize(every)
            @every = every
        end

        def proc(enum, pipe)
            prev = Time.now
            rest = enum.reduce(pipe.unit) {|acc, line|
                tmp = pipe.accumulate(acc, line)
                current = Time.now
                if current - prev > @every
                    pipe.write(tmp)
                    tmp = pipe.unit
                    prev = current
                end
                tmp
            }
            pipe.write(rest)
        end
    end
end
