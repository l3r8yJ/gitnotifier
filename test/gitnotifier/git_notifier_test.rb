require 'test_helper'
require 'gitnotifier/version'
require 'minitest/autorun'

class GitNotifierTest < MiniTest::Test
  def test_that_it_has_a_version_number
    refute_nil GitNotifier::VERSION
  end
end
