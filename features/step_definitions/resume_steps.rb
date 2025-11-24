require 'tempfile'

When(/^I attach "([^"]+)" to "([^"]+)"$/) do |relative_path, field|
  path = File.expand_path(relative_path, Dir.pwd)
  attach_file(field, path)
end

When("I attach a non-pdf file to {string}") do |field|
  path = File.expand_path("spec/fixtures/files/sample.txt", Dir.pwd)
  attach_file(field, path)
end

When("I attach an oversized file to {string}") do |field|
  tmp_dir = File.join(Dir.pwd, 'tmp')
  Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
  path = File.join(tmp_dir, "cucumber_oversized.pdf")
  File.open(path, 'wb') do |f|
    f.write("0" * (5 * 1024 * 1024 + 1))
    f.flush
  end
  attach_file(field, path)
end

Then("I should see my resume file attached") do
  link = page.first("a", text: "View")
  expect(link).not_to be_nil
  href = link[:href]
  expect(href).to match(/rails\/active_storage|blob/)
end
