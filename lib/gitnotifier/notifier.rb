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
require_relative 'user'
require_relative 'users'
require_relative 'client'
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

  START = '
  Hello, i\'ll notify you! Please, send /auth YOUR_TOKEN to authorize and /reset YOUR_TOKEN to set new.
  '.freeze

  def initialize
    config = YAML.load_file('.notifier.yml')
    @token = config['bot']['token']
    @logger = Logger.new($stdout)
    @pgsql = PG.connect(
      host: config['database']['host'],
      user: config['database']['user'],
      password: config['database']['password'],
      dbname: config['database']['schema']
    )
  end

  def run
    Telegram::Bot::Client.run(@token) do |bot|
      @logger.info('Bot started!')
      @process = Thread.new { Client.new(bot).handle }
      bot.listen do |message|
        send_start_text(bot, message) if start?(message)
        send_auth_message(bot, message) if auth?(message)
        send_reset_message(bot, message) if reset?(message)
      end
    end
  end

  private

  def send_start_text(bot, message)
    bot.api.send_message(
      chat_id: message.chat.id,
      text: START
    )
  end

  def start?(message)
    message.text.include?('/start')
  end

  def send_auth_message(bot, message)
    txt = save_user(message)
    bot.api.send_message(
      chat_id: message.chat.id,
      text: txt
    )
    reboot_process(bot) if txt.include?('success')
  end

  def auth?(message)
    message.text.include?('/auth')
  end

  def send_reset_message(bot, message)
    txt = update_user_token(message)
    bot.api.send_message(
      chat_id: message.chat.id,
      text: txt
    )
    reboot_process(bot) if txt.include?('success')
  end

  def reset?(message)
    message.text.include?('/reset')
  end

  def reboot_process(bot)
    @process.kill
    @process = Thread.new { Client.new(bot).handle }
  end

  def save_user(message)
    token = token('/auth', message)
    txt = 'Your token successfully registred!'
    txt = incorrect_token_txt(txt, token)
    begin
      @logger.info("Trying to register the user #{message.from.id}")
      User.new(message.from.id, token, @pgsql).save if valid?(token)
    rescue PG::UniqueViolation => e
      txt = 'You already registred your token!'
      @logger.error("Error: #{e}")
    end
    txt
  end

  def update_user_token(message)
    token = token('/reset', message)
    txt = 'Token successfully updated!'
    txt = incorrect_token_txt(txt, token)
    begin
      if valid?(token)
        @logger.info("Trying to update #{message.from.id} token")
        User.new(
          message.from.id,
          token,
          @pgsql
        )
        .fetch
        .update_token(token)
        @logger.info("Token for #{message.from.id} updated")
      end
    rescue KeyError => e
      txt = 'You\'re not registered, please use /auth'
      @logger.error(e.to_s)
    end
    txt
  end

  def incorrect_token_txt(txt, token)
    txt = 'Please enter correct token.' unless valid?(token)
    txt
  end

  def token(command, message)
    message.text.gsub(command, '').gsub(' ', '')
  end

  def valid?(token)
    /^ghp_[a-zA-Z0-9]{36}$/.match?(token)
  end
end
