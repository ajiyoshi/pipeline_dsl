$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pipeline_dsl'

def tsv_to_hash(str)
    str.chomp.split(/\n/).reduce({}) {|acc, line|
        key, val = line.split(/\t/)
        acc[key] = val
        acc
    }
end

