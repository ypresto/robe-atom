#!/usr/bin/env ruby

robe_ruby_path = ARGV[0]

unless defined? Robe
  $LOAD_PATH.unshift(robe_ruby_path + '/lib')
  require 'robe'
end
p Robe.start(0)

# override Robe's signal trapping
%w(INT TERM).each do |signal|
  trap(signal) { exit }
end

# wait until EOF (= parent exit)
STDIN.each_line {}
