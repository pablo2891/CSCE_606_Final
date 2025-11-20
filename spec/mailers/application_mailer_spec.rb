require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  it 'has the default from' do
    expect(ApplicationMailer.default[:from]).to eq('LinkedOut <no-reply@linkedout.local>')
  end
end
