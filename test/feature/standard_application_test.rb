require_relative '../test_helper'

require 'alki/base'

describe Alki::StandardApplication do
  describe 'example' do
    it 'should do fizzbuzz' do
      app = Alki::StandardApplication.new(File.join(fixtures_path,'example'))
      app.range_handler.handle 1..20
      app.output.to_a.must_equal [
                                     "1","2","Fizz!","4","Buzz!","Fizz!","7", "8", "Fizz!",
                                     "Buzz!", "11", "Fizz!", "13", "14", "Fizzbuzz!", "16",
                                     "17", "Fizz!", "19", "Buzz!"
                                 ]
    end
  end
end