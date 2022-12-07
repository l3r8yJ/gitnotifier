require 'test_helper'
require 'git/notifier'
require 'minitest/autorun'

class NotifierTest < MiniTest::Test
  def test_that_it_has_a_version_number
    refute_nil Git::Notifier::VERSION
  end
end
