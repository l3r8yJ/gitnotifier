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

require 'octokit'
require 'parallel'

# Client class.
# Author:: Ivanchuk Ivan (clicker.heroes.acg@gmail.com)
# Copyright:: Copyright (c) 2022 Ivanchuck Ivan
# License:: MIT
class Client
  def initialize(bot)
    @bot = bot
    @logger = Logger.new($stdout)
  end

  def handle
    users = Users.new.fetch
    @logger.info(users.map(&:id))
    Parallel.each(users, in_threads: users.size) { |u| handle_single(u) }
  end

  def handle_single(user)
    client = Octokit::Client.new(access_token: user.token)
    before = client.notifications({ all: false }).map { |n| n['id'] }
    Kernel.loop do
      current = client.notifications({ all: false }).map { |n| n['id'] }
      diff = current - before
      unless diff.empty?
        @bot.api.send_message(
          chat_id: user.id,
          text: "[#{client.user.login}] new notifications, take a look, please."
        )
        before = current
      end
      sleep(2)
    end
  end
end
