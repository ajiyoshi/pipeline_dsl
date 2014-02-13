require 'spec_helper'

include PipelineDsl

describe PipelineDsl do
    it 'should have a version number' do
        VERSION.should_not be_nil
    end

    before(:each) do
        @out1 = StringIO.new("", "w")
        @out2 = StringIO.new("", "w")
        @wc = WordCount.new
    end

    it 'should do cat input' do
        input = StringIO.new("hoge hoge fuga\nboo")

        cat(input) { @out1 }

        @out1.string.chomp.should eq("hoge hoge fuga\nboo")
    end

    it 'should word counter' do
        input = StringIO.new("hoge hoge fuga\nboo")

        cat(input) { @wc | @out1 }

        wc_result = tsv_to_hash(@out1.string)
        wc_result.should eq({"boo"=>"1", "fuga"=>"1", "hoge"=>"2"})
    end

    it 'should grep' do
        input = StringIO.new("heaven or hell\nhell hello\nhello world")

        cat(input) { grep(/^hell/) | @out1 }

        @out1.string.chomp.should eq("hell hello\nhello world")
    end

    it 'should grep | wc ' do
        input = StringIO.new("heaven or hell\nhell hello\nhello world")

        cat(input) { grep(/^hell/) | @wc | @out1 }

        wc_result = tsv_to_hash(@out1.string.chomp)
        wc_result.should eq({"world"=>"1", "hello"=>"2", "hell"=>"1"})
    end

    it 'should multi pipeline' do
        input = StringIO.new("heaven or hell\nhell hello\nhello world")

        cat(input) { multi(
            @wc | @out1,
            grep(/hello/) | @out2
        ) }

        wc_result = tsv_to_hash(@out1.string.chomp)
        wc_result.should eq({"world"=>"1", "or"=>"1", "hello"=>"2", "hell"=>"2", "heaven"=>"1"})
        @out2.string.chomp.should eq("hell hello\nhello world")
    end

    it 'should multiオブジェクト自体の出力を設定' do
        input = StringIO.new("heaven or hell\nhell hello\nhello world")

        cat(input) { 
            multi(@wc) | @out1 
        }

        wc_result = tsv_to_hash(@out1.string.chomp)
        wc_result.should eq({"world"=>"1", "or"=>"1", "hello"=>"2", "hell"=>"2", "heaven"=>"1"})
    end

    it 'should multiに渡すコマンドに出力が設定されていたらそれを使い、省略されていたらmultiの出力を使う' do
        input = StringIO.new("heaven or hell\nhell hello\nhello world")

        cat(input) {
            multi( @wc, grep(/hello/) | @out2 ) | @out1
        }

        wc_result = tsv_to_hash(@out1.string.chomp)
        wc_result.should eq({"world"=>"1", "or"=>"1", "hello"=>"2", "hell"=>"2", "heaven"=>"1"})
        @out2.string.chomp.should eq("hell hello\nhello world")
    end

    it 'should パイプを3段渡せる' do
        input = StringIO.new("1234\n123\n13\n14")

        cat(input) {
            grep(/3/) | grep(/1/) | grep(/4/) | @out1
        }

        @out1.string.chomp.should eq("1234")
    end

end
