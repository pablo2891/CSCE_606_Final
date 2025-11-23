# Specific steps for form actions to avoid ambiguity
When("I fill in form {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I click form {string}") do |button_text|
  if page.has_button?(button_text)
    click_button button_text
  else
    click_link button_text
  end
end

# Specific steps for experience actions
When("I click experience {string}") do |button_text|
  within("#experiences") do
    if page.has_button?(button_text)
      click_button button_text
    else
      click_link button_text
    end
  end
end

# Specific steps for navigation
When("I click navigation {string}") do |button_text|
  if page.has_button?(button_text)
    click_button button_text
  else
    click_link button_text
  end
end

# Common redirect step
Then('I should be redirected to conversations page') do
  expect(page.current_path).to eq(conversations_path)
end

# Common redirect step
Then('I should be redirected to new session path') do
  expect(page).to have_current_path(new_session_path)
end
