# PipelineDsl

A DSL like the UNIX shell pipeline.

## Installation

Add this line to your application's Gemfile:

     gem 'pipeline_dsl', :git => 'https://github.com/ajiyoshi/pipeline_dsl.git'

And then execute:

    $ bundle

## Usage

Simple usage.
Just read stdin and write to stdout.

```ruby
require 'pipeline_dsl'
include PipelineDsl

cat(STDIN) {
    STDOUT
}
```

You can connect stream with '|' like unix shell.
(PipelineDsl::grep is a built in command)

```ruby
cat(STDIN) {
    grep(/android/) | STDOUT
}
```

When you ommit output IO, it will write to stdout.

```ruby
cat(STDIN) {
    grep(/android/)
}
```

You can connect command streams with '|' like unix shell.

```ruby
wc = WordCount.new
cat(STDIN) {
    grep(/android/) | wc 
}
```

You can redirect the stream to a file with '>' like unix shell

```ruby
cat(STDIN) {
    grep(/android/) | wc > 'android.txt'
}
```

'>>' is the append mode.

```ruby
cat(STDIN) {
    grep(/android/) | wc >> 'android.txt'
}
```

You can split input stream and write it into multiple streams.

```ruby
cat(STDIN) {
    multi (
        grep(/android/) | wc > 'android.txt',
        grep(/iphone/i) | wc > 'iphone.txt'
    )
}
```

You can write your custom command. mapper(), unit(), reducer() and write() are required.

```ruby
    class WordCount < PipelineDsl::Command
        def mapper line
            line.chomp.split(/\s/)
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

cat(STDIN) {
    WordCount.new | grep(/hello/) | STDERR
}
    
```

A command will be executed like below.

```ruby

cmd = YourCommand.new

result = theInput.flat_map { |rec|
    cmd.mapper(rec)
}.reduce( cmd.unit ) {|acc, rec|
    cmd.reducer(acc, rec)
}

theOutput.puts( cmd.writer(result) )
```

If you don't need reduce, then include PipelineDsl::SimpleMapper.

```ruby
class Grep < PipelineDsl::Command
    include PipelineDsl::SimpleMapper

    def initialize(re)
        @re = re
    end

    def mapper(line)
        @re.match(line) ? [ line ] : []
    end
end

cat(STDIN) {
    Grep.new(/hoge/)
}
```



## Contributing

1. Fork it ( http://github.com/ajiyoshi/pipeline_dsl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
