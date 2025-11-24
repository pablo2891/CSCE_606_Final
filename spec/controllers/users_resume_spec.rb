require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  let!(:user) do
    User.create!(email: "res.user@tamu.edu", first_name: "Res", last_name: "User", password: "password")
  end

  before do
    session[:user_id] = user.id
  end

  describe 'PATCH #update resume' do
    it 'accepts a PDF resume' do
      pdf = fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.pdf'), 'application/pdf')
      patch :update, params: { id: user.id, user: { resume: pdf } }
      expect(response).to redirect_to(user_path(user))
      user.reload
      expect(user.resume.attached?).to be true
    end

    it 'rejects non-PDF resume' do
      txt = fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.txt'), 'text/plain')
      patch :update, params: { id: user.id, user: { resume: txt } }
      expect(response).to render_template(:edit)
      user.reload
      expect(user.resume.attached?).to be false
      expect(assigns(:user).errors[:resume]).to include("must be a PDF")
    end

    it 'rejects oversized resume' do
      tmp = Tempfile.new([ 'big', '.pdf' ])
      tmp.binmode
      tmp.write("0" * (6 * 1024 * 1024))
      tmp.rewind
      uploaded = Rack::Test::UploadedFile.new(tmp.path, 'application/pdf')
      patch :update, params: { id: user.id, user: { resume: uploaded } }
      expect(response).to render_template(:edit)
      user.reload
      expect(user.resume.attached?).to be false
      expect(assigns(:user).errors[:resume]).to include("size must be less than 5 MB")
      tmp.close!
    end
  end
end
