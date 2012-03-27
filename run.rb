require 'rubygems'
require 'bundler/setup'

require 'capybara'
require 'capybara/dsl'
require 'active_support/core_ext'
require 'kopflos'

begin
  Settings = YAML.load File.read('settings.yml')
rescue Errno::ENOENT => e
  STDERR.puts "please copy the settings.yml.example to settings.yml and fill in you credentials"
  raise e
end


Capybara.current_driver = :selenium
Capybara.run_server = false
Kopflos.start

include Capybara::DSL

def assert_content(page, content)
  page.has_content?(content) || raise(RuntimeError, "could not find '#{content}' on page")
end

today = Date.today
monday = (today.beginning_of_week + 1.week)

visit "https://extranet.cnetchannel.com"
fill_in 'login:', with: Settings['login']
fill_in 'password:', with: Settings['password']
click_button "Sign In"

assert_content page, 'Log off'

# cannot click link, it's hover-activated
visit "https://extranet.cnetchannel.com/full-dump-request.aspx"
assert_content page, 'Full Dump Request'

unless page.has_content?(monday.strftime('%m/%d/%Y'))
  choose('Full Dump')
  click_button "Submit"
  assert_content page, today.strftime('%m/%d/%Y')
  assert_content page, monday.strftime('%m/%d/%Y')
  puts "Full Dump requested, delivery on #{monday}"
else
  puts "Full Dump already requested, delivery on #{monday}"
end
