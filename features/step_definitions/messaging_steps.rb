Given("another user {string} exists") do |full_name|
  first_name, last_name = full_name.split(" ")
  @other_user = User.find_or_create_by!(
    first_name: first_name,
    last_name: last_name,
    email: "#{first_name.downcase}.#{last_name.downcase}@tamu.edu"
  ) do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
  end
end

Given("I have a conversation with {string}") do |full_name|
  first_name, last_name = full_name.split(" ")
  other_user = User.find_by(first_name: first_name, last_name: last_name)

  @conversation = Conversation.create!(
    sender: @user,
    recipient: other_user,
    subject: "Test Conversation"
  )
end

Given("the conversation has messages") do
  Message.create!(
    conversation: @conversation,
    user: @conversation.recipient,
    body: "Hello from the other user!",
    read: false
  )

  Message.create!(
    conversation: @conversation,
    user: @user,
    body: "My reply",
    read: false
  )
end

When("I visit the conversations page") do
  visit conversations_path
end

When("I visit the conversation with {string}") do |full_name|
  first_name, last_name = full_name.split(" ")
  other_user = User.find_by(first_name: first_name, last_name: last_name)
  conversation = Conversation.between(@user.id, other_user.id)

  visit conversation_path(conversation)
end

When("I start a conversation with {string}") do |full_name|
  first_name, last_name = full_name.split(" ")
  other_user = User.find_by(first_name: first_name, last_name: last_name)

  visit conversations_path

  page.driver.post conversations_path, {
    recipient_id: other_user.id,
    subject: "New Conversation",
    body: "Hello!"
  }

  visit conversations_path
end

When("I send a message {string}") do |message_text|
  # Try different ways to find the message body field
  if page.has_field?("message_body")
    fill_in "message_body", with: message_text
  elsif page.has_field?("Body")
    fill_in "Body", with: message_text
  else
    # Find any textarea
    find('textarea').set(message_text)
  end
  click_button "Send"
end

When("I delete the conversation") do
  click_button "Delete", match: :first
end

Then("I should see my conversations list") do
  expect(page).to have_content("Conversations")
end

Then("I should see {string} in my conversations") do |name|
  expect(page).to have_content(name)
end

Then("I should see the message {string}") do |message_text|
  expect(page).to have_content(message_text)
end

Then("the message should be marked as read") do
  unread_count = Message.where(
    conversation: @conversation,
    user: @conversation.recipient,
    read: false
  ).count

  expect(unread_count).to eq(0)
end

Then("I should be on the conversation page") do
  expect(page.current_path).to match(/\/conversations\/\d+/)
end

Then("I should not see the conversation with {string}") do |name|
  expect(page).not_to have_content(name)
end

Given('another user exists {string} {string}') do |first_name, last_name|
  @other_user = User.find_or_create_by!(
    first_name: first_name,
    last_name: last_name,
    email: "#{first_name.downcase}.#{last_name.downcase}@tamu.edu"
  ) do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
end

Given('there is a conversation between current user and {string} {string}') do |first_name, last_name|
  other_user = User.find_by(first_name: first_name, last_name: last_name)
  @conversation = Conversation.create!(
    sender: @user,
    recipient: other_user,
    subject: 'Test Conversation'
  )
end

When('I visit the conversation page for the last conversation') do
  visit conversation_path(Conversation.last)
end

Given('there is a conversation between {string} {string} and {string} {string}') do |first1, last1, first2, last2|
  user1 = User.find_by(first_name: first1, last_name: last1)
  user2 = User.find_by(first_name: first2, last_name: last2)

  @other_conversation = Conversation.create!(
    sender: user1,
    recipient: user2,
    subject: 'Private Conversation'
  )
end

When('I try to send a message to their conversation') do
  # Try to send message to conversation that doesn't belong to current user
  conversation = @other_conversation || Conversation.where.not(sender: @user).where.not(recipient: @user).first
  page.driver.post conversation_messages_path(conversation), { message: { body: 'Test message' } }
  visit conversation_path(conversation)
end

When("I fill in {string} with {string}") do |field, value|
  if field == "Body"
    fill_in "message_body", with: value
  else
    fill_in field, with: value
  end
end

When("I click {string}") do |button_text|
  if page.has_button?(button_text)
    click_button button_text
  else
    click_link button_text
  end
end

When("I click message {string}") do |button_text|
  if button_text == "Send Message"
    click_button "Send"
  else
    if page.has_button?(button_text)
      click_button button_text
    else
      click_link button_text
    end
  end
end

When("I click conversation {string}") do |button_text|
  if page.has_button?(button_text)
    click_button button_text
  else
    click_link button_text
  end
end

When("I click send message button") do
  click_button "Send"
end

When("I try to view the conversation between {string} and {string}") do |user1_name, user2_name|
  first1, last1 = user1_name.split(" ")
  first2, last2 = user2_name.split(" ")

  user1 = User.find_by(first_name: first1, last_name: last1)
  user2 = User.find_by(first_name: first2, last_name: last2)

  conversation = Conversation.between(user1.id, user2.id)

  visit conversation_path(conversation)
end

Given('the conversation has unread messages from {string}') do |full_name|
  first, last = full_name.split(" ")
  sender = User.find_by(first_name: first, last_name: last)

  # Ensure @conversation exists
  raise "No @conversation set before this step" unless @conversation

  Message.create!(
    conversation: @conversation,
    user: sender,
    body: "Unread message from #{full_name}",
    read: false
  )
end

Given('there is a conversation between {string} and {string}') do |name1, name2|
  first1, last1 = name1.split(" ")
  first2, last2 = name2.split(" ")

  user1 = User.find_by(first_name: first1, last_name: last1)
  user2 = User.find_by(first_name: first2, last_name: last2)

  @conversation = Conversation.create!(
    sender: user1,
    recipient: user2,
    subject: "Private Conversation"
  )
end
