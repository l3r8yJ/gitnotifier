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

require 'chilkat'

# EcnryptionBody class.
# Author:: Ivanchuk Ivan (clicker.heroes.acg@gmail.com)
# Copyright:: Copyright (c) 2022 Ivanchuck Ivan
# License:: MIT
# @todo #28 Decompose class.
# Decompose this class into two decorators for string.
# First should be Encrypted, second one should be Decrypted
class EncryptionBody
  def initialize(token)
    @token = token
    @crypt = Chilkat::CkCrypt2.new
    prepare
  end

  def encrypted
    @crypt.encryptStringENC(@token)
  end

  def decrypted
    @crypt.decryptStringENC(@token)
  end

  private

  def prepare
    # @todo #28 Take out the keys.
    # Take out the iv and key into .yml configuration.
    iv = '000102030405060708090A0B0C0D0E0F'
    key = '000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F'
    @crypt.put_CryptAlgorithm('twofish')
    @crypt.put_CipherMode('cbc')
    @crypt.put_KeyLength(256)
    @crypt.put_PaddingScheme(0)
    @crypt.put_EncodingMode('hex')
    @crypt.SetEncodedIV(iv, 'hex')
    @crypt.SetEncodedKey(key, 'hex')
  end
end
