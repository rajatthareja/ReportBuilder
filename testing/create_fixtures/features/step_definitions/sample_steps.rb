Given(/^I am give step of some feature$/) do
end

When(/^I am when step of some feature$/) do
  puts '$ ABC % XYZ £'
end

Then(/^I am then step of some feature$/) do
end

Given(/^I am give step of some other feature$/) do
end

When(/^I am when step of some other feature$/) do
  puts 123
end

Then(/^I am then step of some (other|this) feature$/) do |option|
end

Then(/^I am then step of some pending feature$/) do
  pending
end

When(/^I am when step which will fail$/) do
  raise 'I am some error'
end

When(/^I am step with options:$/) do |table|
  table.hashes
end

And(/^I am step with screenshot$/) do
  browser = Watir::Browser.new :chrome
  browser.goto 'google.com'
  browser.driver.save_screenshot('screenshot.png')
  embed('screenshot.png', 'image/png')
  browser.quit
end