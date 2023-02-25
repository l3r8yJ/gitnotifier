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

require_relative 'user'
require_relative 'security/decrypted_token'
require 'pg'
require 'yaml'
# @todo #38 Redesign user and users class.
# It should be more think about perfomance.

# The users class.
# Author:: Ivanchuk Ivan (clicker.heroes.acg@gmail.com)
# Copyright:: Copyright (c) 2022 Ivanchuck Ivan
# License:: MIT
class Users
  def initialize
    config = YAML.load_file('.notifier.yml')['database']
    @pgsql = PG.connect(
      host: config['host'],
      user: config['user'],
      password: config['password'],
      dbname: config['schema']
    )
  end

  def fetch
    @pgsql.exec('SELECT * FROM bot_user').map do |record|
      User.new(
        record['id'].to_i,
        DecryptedToken.new(u['token']).to_s,
        @pgsql
      )
    end
  end
end
