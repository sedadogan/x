# encoding: utf-8

# Classes
class Foo
  attr_accessor :foo
  def initialize(*)
    @foo = "foo"
  end
end

class Bar < Foo
  attr_accessor :bar
  def initialize(*)
    super
    @bar = "bar"
  end
end

# Modules
class Moo
  def self.moo
    "moo"
  end
end

# String array
A = ('abc'..'abz').to_a unless defined? A

# Number array
N = (1..19).to_a unless defined? N

# Hash
unless defined? H
  H = {}; A.each { |elt| H[elt.to_sym] = "#{elt}_value" }
end
