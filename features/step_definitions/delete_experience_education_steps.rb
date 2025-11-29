And(/^I click "Delete" next to the "([^"]*)" experience$/) do |title|
  # Find the list item containing the experience title
  li = find("ul.list-group li", text: title)
  # Within that li, click the Delete button
  li.click_button("Delete")
end

And(/^I click "Delete" next to the "([^"]*)" education$/) do |degree|
  # Find the list item containing the education degree
  li = find("ul.list-group li", text: degree)
  # Within that li, click the Delete button
  li.click_button("Delete")
end

Given("saving the user should fail") do
  allow_any_instance_of(User).to receive(:save).and_return(false)
end
