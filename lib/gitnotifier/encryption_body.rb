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
require 'yaml'

# EcnryptionBody class.
# Author:: Ivanchuk Ivan (clicker.heroes.acg@gmail.com)
# Copyright:: Copyright (c) 2022 Ivanchuck Ivan
# License:: MIT
class EncryptionBody
  def initialize(token, config = nil)
    @config = config
    @token = token
    @crypt = Chilkat::CkCrypt2.new
  end

  private

  def prepare
    iv = ''
    key = ''
    if @config.nil?
      iv += read_config_from_file[0]
      key += read_config_from_file[1]
    elsif iv += read_own_config[0]
      key += read_own_config[1]
    end
    @crypt.put_CryptAlgorithm('twofish')
    @crypt.put_CipherMode('cbc')
    @crypt.put_KeyLength(256)
    @crypt.put_PaddingScheme(0)
    @crypt.put_EncodingMode('hex')
    @crypt.SetEncodedIV(iv, 'hex')
    @crypt.SetEncodedKey(key, 'hex')
  end

  def read_config_from_file
    @config = YAML.load_file('.notifier.yml')
    [@config['enc']['iv'], @config['enc']['key']]
  end

  def read_own_config
    [@config[:enc][:iv], @config[:enc][:key]]
  end
end
