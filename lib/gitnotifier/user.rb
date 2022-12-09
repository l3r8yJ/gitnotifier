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

require 'pg'
require 'yaml'

# The user class.
# Author:: Ivanchuk Ivan (clicker.heroes.acg@gmail.com)
# Copyright:: Copyright (c) 2022 Ivanchuck Ivan
# License:: MIT
class User
  class UserError < StandardError; end
  # @todo #7 Tests/ test user.
  # We have to write integration and unit tests for User class.
  # @todo #13 Design/ The user class must be separated.
  # It is necessary to decompose into several other classes.
  attr_reader :id, :token

  def initialize(id, token = nil, pgsql = nil)
    @id = id
    @token = token
    @pgsql = pgsql
  end

  def save
    check_token
    @pgsql.exec(
      'INSERT INTO bot_user(id, token) VALUES ($1, $2)',
      [@id, @token]
    )
  end

  def fetch
    check_pgsql
    r = @pgsql.exec(
      'SELECT * FROM bot_user WHERE id=$1',
      [@id]
    )
    User.new(r['id'], r['token'], @pgsql)
  end

  def update_token(token)
    check_pgsql
    @pgsql.exec(
      'UPDATE bot_user SET token=$1 WHERE id=$2',
      [token, @id]
    )
  end

  private

  def check_token
    raise UserError, 'Token token is required.' if @token.nil?
  end

  def check_pgsql
    raise UserError, 'No connection to the database is provided.' if @pgsql.nil?
  end
end
