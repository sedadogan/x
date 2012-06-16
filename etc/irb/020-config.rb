# encoding: utf-8

require 'irbtools/configure'
Irbtools.add_package :more

# sorunlu gem'leri çıkar
%w[zucker/debug].each do |m|
  Irbtools.remove_library 'zucker/debug' rescue nil
end
