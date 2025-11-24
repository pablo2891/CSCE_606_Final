require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(email: 'u1@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'A', last_name: 'B') }

  it 'accepts a PDF attachment' do
    u = User.new(email: 'x@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'A', last_name: 'B')
    u.resume.attach(io: File.open(Rails.root.join('spec/fixtures/files/sample.pdf')), filename: 'sample.pdf', content_type: 'application/pdf')
    expect(u.valid?).to be true
    expect(u.errors[:resume]).to be_blank
  end

  it 'rejects non-pdf attachments at model validation' do
    u = User.new(email: 'y@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'A', last_name: 'B')
    u.resume.attach(io: File.open(Rails.root.join('spec/fixtures/files/sample.txt')), filename: 'sample.txt', content_type: 'text/plain')
    expect(u.valid?).to be false
    expect(u.errors[:resume]).to include('must be a PDF')
  end

  it 'rejects oversized attachments at model validation' do
    u = User.new(email: 'z@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'A', last_name: 'B')
    tmp = Tempfile.new([ 'big', '.pdf' ])
    tmp.binmode
    tmp.write('0' * (6 * 1024 * 1024))
    tmp.rewind
    u.resume.attach(io: tmp, filename: 'big.pdf', content_type: 'application/pdf')
    expect(u.valid?).to be false
    expect(u.errors[:resume]).to include('size must be less than 5 MB')
    tmp.close!
  end
end
