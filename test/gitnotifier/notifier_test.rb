require_relative '../../lib/gitnotifier/gitnotifier'

require 'test_helper'
require 'gitnotifier/version'
require 'minitest/autorun'

class NotifierTest < MiniTest::Test
  def test_that_it_has_a_version_number
    refute_nil GitNotifier::VERSION
  end

  def test_token_accepted
    assert_equal('tkn', Notifier.new('tkn').token)
  end
end
