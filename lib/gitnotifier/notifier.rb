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

require_relative 'version'
require 'telegram/bot'
require 'yaml'

# GitNotifier class.
# Author:: Ivanchuk Ivan (clicker.heroes.acg@gmail.com)
# Copyright:: Copyright (c) 2022 Ivanchuck Ivan
# License:: MIT
class Notifier
  # @todo #7 Tests/ test bot.
  # We have to write integration and unit tests for Notifier class.
  class NotifierError < StandardError; end

  def initialize
    @token = YAML.load_file('bot.yml')['bot']['token']
    @start = 'Hello, i\'ll notify you! Please, send /auth YOUR_TOKEN to authorize!'
  end

  def run
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen do |message|
        if message.text.include?('/start')
          bot.api.send_message(
            chat_id: message.chat.id,
            text: @start
          )
        end
        if message.text.include?('/auth')
          token = token(message)
          msg = "Your token is: #{token}"
          msg = 'Please enter correct token' unless valid?(token)
          bot.api.send_message(
            chat_id: message.chat.id,
            text: msg
          )
        end
      end
    end
  end

  private

  def token(message)
    message.text.gsub('/auth', '').gsub(' ', '')
  end

  def valid?(token)
    /^ghp_[a-zA-Z0-9]{36}$/.match?(token)
  end
end
