Before do
end

AfterStep do
end

After do |scenario|
  if scenario.failed? and scenario.source_tag_names.include?('@screenshot')
    driver = Selenium::WebDriver.for :chrome
    driver.get('http://www.google.com')
    encoded_img = driver.screenshot_as(:base64)
    embed(encoded_img, "image/png")
    driver.quit
  end
end