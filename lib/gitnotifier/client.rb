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
    Parallel.each(users, in_threads: users.size) { |user| handle_single(user) }
  end

  private

  def handle_single(user)
    client = Octokit::Client.new(access_token: user.token)
    before = notifications(client)
    Kernel.loop do
      current = notifications(client)
      diff = current - before
      unless diff.empty?
        txt = notification_text(new_notifications(client, diff))
        @bot.api.send_message(chat_id: user.id, text: txt, parse_mode: 'Markdown')
        before = current
      end
      sleep(2)
    end
  end

  def notifications(client)
    client.notifications({ all: false }).map { |n| n['id'] }
  end

  def notification_text(updates)
    txt = "[#{client.user.login}] new [notification](https://github.com/notifications):\n"
    updates.each do |update|
      txt.concat("New #{update.reason} in #{update.subject.type}.\n")
    end
    txt.concat('Take a look, please.')
  end

  def new_notifications(client, diff)
    client.notifications({ all: false }).map { |n| n if diff.include?(n['id']) }
  end
end
