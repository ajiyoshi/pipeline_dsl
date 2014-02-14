
module PipelineDsl
    class Command

        # | :: Puttable -> Pipe( self => Puttable )
        def |(dest)
            ret = PipelineDsl::pipe(self)
            PipelineDsl::connect!(ret, dest)
            ret
        end

        def > (path)
            self | open(path, "w")
        end

        def >> (path)
            self | open(path, "a")
        end

    end

    module SimpleMapper
        def unit
            []
        end

        def reducer(acc, rec)
            acc.push(rec)
        end

        def writer(rec)
            rec
        end
    end

    def connect!(from, dest)
        to = build(dest)
        to.parent!(from)
        from.output!(to)
    end
    module_function :connect!

    class BasePipe
        def parent!(dest)
            @parent = dest
            self
        end

        def output!(to)
            @output = to
            self
        end

        def out
            if @output.nil?
                _out_recursive([self])
            else
                @output
            end
        end

        def out_old
            if @output.nil?
                parent.nil? ? nil : parent.out
            else
                @output
            end
        end

        def _out_recursive(excepts)
            if @output.nil? || excepts.any?{|e| e.equal?(@output) }
                if parent.nil?
                    nil
                else
                    parent._out_recursive(excepts.push(self))
                end
            else
                @output
            end
        end

        def strategy
            @strategy.nil? ? BufferStrategy.get : @strategy
        end

        def strategy!(strategy)
            @strategy = strategy
        end

        def parent() @parent end

        def | (dest)
            if @output.is_a?(BasePipe)
                @output | dest
            elsif @output.nil?
                PipelineDsl::connect!(self, dest)
            end
            self
        end

        def > (path)
            self | open(path, "w")
        end

        def >> (path)
            self | open(path, "a") 
        end
    end

    def pipe(task)
        ConcretePipe::Simple.new(task)
    end
    module_function :pipe

    def build(dest)
        if dest.is_a?(BasePipe)
            dest
        elsif dest.is_a?(Command)
            pipe(dest)
        else
            ConcretePipe::IO.new(dest)
        end
    end
    module_function :build

end

