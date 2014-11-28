module  PipelineDsl

    module ConcretePipe

        class Simple < BasePipe
            def initialize(task)
                @task = task
            end

            def unit
                @task.unit
            end

            def accumulate(acc, rec)
                @task.mapper(rec).reduce(acc) {|tmp, x|
                    @task.reducer(tmp, x)
                }
            end

            def write(rec)
                out.puts(@task.writer(rec))
            end

            def puts(enum)
                strategy.proc(enum, self)
            end

            def to_s
                "{ cmd(%s) -> %s }" % [ @task.class, out.to_s ]
            end

        end

        class IO < BasePipe
            def initialize(io)
                @output = io
            end
            def unit() 
                []
            end

            def accumulate(acc, rec)
                acc.push(rec)
            end

            def write(rec)
                @output.puts(rec)
            end

            def puts(enum)
                strategy.proc(enum, self)
            end

            def to_s
                "{ IO : %s }" % [ @output.class ]
            end

        end

        class Split < BasePipe
            def initialize(dests)
                @dests = dests.map {|d|
                    PipelineDsl::build(d).parent!(self)
                }
            end

            def unit
                @dests.map {|d| [d, d.unit] }
            end

            def accumulate(accs, rec)
                accs.map {|dest, acc|
                    [ dest, dest.accumulate(acc, rec) ]
                }
            end

            def each(&block)
                @dests.each {|x|
                    block[x]
                }
            end

            def write(acc)
                acc.each {|dest, rec|
                    dest.write(rec)
                }
            end

            def puts(enum)
                strategy.proc(enum, self)
            end

            def to_s
                "{ multi (\n%s\n) -> %s }" % [ @dests.map {|d| d.to_s}.join("\n"), out.class ]
            end

        end

        class Partition < BasePipe
            def initialize(ok_case, ng_case, &pred)
                @ok_case = PipelineDsl::build(ok_case).parent!(self)
                @ng_case = PipelineDsl::build(ng_case).parent!(self)
                @pred = pred
            end

            def unit
                [@ok_case.unit, @ng_case.unit]
            end

            def accumulate(accs, rec)
                ok, ng = accs
                if @pred[rec]
                    [ @ok_case.accumulate(ok, rec), ng ]
                else
                    [ ok, @ng_case.accumulate(ng, rec) ]
                end
            end

            def write(accs)
                ok, ng = accs
                @ok_case.write(ok)
                @ng_case.write(ng)
            end

            def puts(enum)
                strategy.proc(enum, self)
            end

            def to_s
                "{ partition (\n%s, %s\n) -> %s }" % [ @ok_case.to_s, @ng_case.to_s, out.class ]
            end

        end
    end
end

