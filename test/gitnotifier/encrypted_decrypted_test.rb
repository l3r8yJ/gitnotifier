# Copyright (c) 2022 Ivanchuck Ivan
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require_relative '../../lib/gitnotifier/security/encrypted_token'
require_relative '../../lib/gitnotifier/security/decrypted_token'
require 'test_helper'
require 'tmpdir'
require 'tempfile'
require 'yaml'
require 'gitnotifier/version'
require 'minitest/autorun'

# Test for EcnryptedToken class.
# Author:: Ivanchuk Ivan (clicker.heroes.acg@gmail.com)
# Copyright:: Copyright (c) 2022 Ivanchuck Ivan
# License:: MIT

class EncryptedDecryptedTokenTest < MiniTest::Test
  def test_ecnrypted_token
    refute_same(
      token,
      EncryptedToken.new(token, config).to_s
    )
  end

  def test_decrypted_token
    refute_same(
      token,
      DecryptedToken.new(token, config).to_s
    )
  end

  def test_ecnryption_decryption
    encrypted = EncryptedToken.new(token, config).to_s
    assert_equal(
      token,
      DecryptedToken.new(encrypted, config).to_s
    )
  end

  def config
    y = {
      enc: {
        iv: '034136030405060704020A0B0C0D0E0F',
        key: '000102030405215535124A0B0C0D0E0F101112131415161718191A1B1C1D1E1F'
      }
    }
      .to_yaml
    YAML.safe_load(y, permitted_classes: [Symbol])
  end

  def token
    'ghg_ASkn2Kjkd1413kaSd'
  end
end
