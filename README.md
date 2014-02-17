# PipelineDsl

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'pipeline_dsl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pipeline_dsl

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
(PipelineDsl::wc is a built in command)

```ruby
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



## Contributing

1. Fork it ( http://github.com/ajiyoshi/pipeline_dsl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
