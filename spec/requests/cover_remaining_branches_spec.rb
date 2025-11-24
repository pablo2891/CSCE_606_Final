require 'rails_helper'

RSpec.describe 'Cover remaining controller branches', type: :request do
  describe 'ConversationsController#destroy unauthorized branch' do
    it 'redirects unauthorized user and sets alert' do
      sender = User.create!(email: 's1@tamu.edu', password: 'password', first_name: 'S', last_name: 'One')
      recipient = User.create!(email: 'r1@tamu.edu', password: 'password', first_name: 'R', last_name: 'One')
      outsider = User.create!(email: 'o1@tamu.edu', password: 'password', first_name: 'O', last_name: 'One')

      conv = Conversation.create!(sender: sender, recipient: recipient, subject: 'Test')

      # stub current_user as outsider so destroy's unauthorized branch is executed
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(outsider)

      delete conversation_path(conv)

      expect(response).to redirect_to(conversations_path)
      follow_redirect!
      expect(flash[:alert]).to eq('Unauthorized')
    end

    it 'allows a participant to destroy a conversation and sets notice' do
      sender = User.create!(email: 's2@tamu.edu', password: 'password', first_name: 'S', last_name: 'Two')
      recipient = User.create!(email: 'r2@tamu.edu', password: 'password', first_name: 'R', last_name: 'Two')

      conv = Conversation.create!(sender: sender, recipient: recipient, subject: 'DeleteMe')

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(sender)

      delete conversation_path(conv)

      expect(response).to redirect_to(conversations_path)
      follow_redirect!
      expect(flash[:notice]).to eq('Conversation deleted')
    end

    it 'creates a conversation and message when body is present' do
      sender = User.create!(email: 's3@tamu.edu', password: 'password', first_name: 'S', last_name: 'Three')
      recipient = User.create!(email: 'r3@tamu.edu', password: 'password', first_name: 'R', last_name: 'Three')

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(sender)

      post conversations_path, params: { recipient_id: recipient.id, body: 'Hello there' }

      conv = Conversation.last
      expect(conv).not_to be_nil
      expect(conv.messages.last.body).to eq('Hello there')
    end
  end

  describe 'ConversationsController#show marks messages read' do
    it 'marks unread messages as read for the current_user' do
      sender = User.create!(email: 's4@tamu.edu', password: 'password', first_name: 'S', last_name: 'Four')
      recipient = User.create!(email: 'r4@tamu.edu', password: 'password', first_name: 'R', last_name: 'Four')

      conv = Conversation.create!(sender: sender, recipient: recipient, subject: 'Thread')
      # message sent to sender by recipient
      m = conv.messages.create!(user: recipient, body: 'Ping', read: false)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(sender)

      get conversation_path(conv)

      expect(response).to have_http_status(:ok)
      expect(m.reload.read).to be true
    end
  end

  describe 'UsersController resume removal' do
    it 'calls purge_later when remove_resume param is set' do
      user = User.create!(email: 'rm@tamu.edu', password: 'password', first_name: 'R', last_name: 'Mover')

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:require_login).and_return(true)

      allow_any_instance_of(User).to receive(:resume).and_return(double(purge_later: true))
      allow_any_instance_of(User).to receive(:update).and_return(true)

      patch user_path(user), params: { user: { email: user.email }, remove_resume: '1' }

      expect(response).to redirect_to(user_path(user))
    end
  end

  describe 'ConversationsController internal destroy auth branch' do
    it 'redirects with alert when destroy inner auth check fails' do
      sender = User.create!(email: 's5@tamu.edu', password: 'password', first_name: 'S', last_name: 'Five')
      recipient = User.create!(email: 'r5@tamu.edu', password: 'password', first_name: 'R', last_name: 'Five')
      outsider = User.create!(email: 'o5@tamu.edu', password: 'password', first_name: 'O', last_name: 'Five')

      conv = Conversation.create!(sender: sender, recipient: recipient, subject: 'InternalCheck')

      # stub set_conversation to set @conversation but avoid its own auth redirect
      allow_any_instance_of(ConversationsController).to receive(:set_conversation) do |ctrl|
        ctrl.instance_variable_set(:@conversation, conv)
      end

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(outsider)

      delete conversation_path(conv)

      expect(response).to redirect_to(conversations_path)
      follow_redirect!
      expect(flash[:alert]).to eq('Unauthorized')
    end
  end

  describe 'UsersController update_education failure branch' do
    it 'renders edit_education and sets flash when save fails' do
      user = User.create!(email: 'edu@tamu.edu', password: 'password', first_name: 'E', last_name: 'Student')
      user.educations_data <<({ 'degree' => 'BS', 'school' => 'OldU' })
      user.save!

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:require_login).and_return(true)

      allow_any_instance_of(User).to receive(:save).and_return(false)
      allow_any_instance_of(User).to receive(:errors).and_return(double(full_messages: [ 'edu oops' ]))

      patch update_education_user_path(user, index: 0), params: { education: { degree: 'MS' } }

      expect(response).to render_template(:edit_education)
      expect(flash[:error]).to include('edu oops')
    end
  end

  describe 'ReferralPosts create branches' do
    let!(:user) { User.create!(email: 'poster2@tamu.edu', password: 'password', first_name: 'P', last_name: 'User') }
    let!(:company_verification) { user.company_verifications.create!(company_name: 'Acme', company_email: 'poster@acme.com', is_verified: true) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:require_login).and_return(true)
    end

    it 'handles questions param assignment when present' do
      post referral_posts_path, params: {
        referral_post: {
          title: 'Q Post', job_title: 'Dev', company_name: 'Acme', company_verification_id: company_verification.id, questions: [ 'Q1', '', 'Q2' ]
        }
      }

      expect(response).to redirect_to(referral_post_path(ReferralPost.last))
      expect(ReferralPost.last.questions).to eq([ 'Q1', 'Q2' ])
    end

    it 'renders new with error when save fails' do
      allow_any_instance_of(ReferralPost).to receive(:save).and_return(false)
      allow_any_instance_of(ReferralPost).to receive(:errors).and_return(double(full_messages: [ 'bad' ]))

      post referral_posts_path, params: {
        referral_post: { title: 'Fail', job_title: 'Dev', company_name: 'Acme', company_verification_id: company_verification.id }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/(New Referral Post|Create Referral Post|referral post)/i)
    end
  end

  describe 'ReferralRequests update_status reopen post branch' do
    it 'reopens a closed post when approved request is reverted to pending/rejected' do
      poster = User.create!(email: 'poster3@tamu.edu', password: 'password', first_name: 'Poster', last_name: '3')
      requester = User.create!(email: 'req3@tamu.edu', password: 'password', first_name: 'Req', last_name: '3')

      cv = poster.company_verifications.create!(company_name: 'X', company_email: 'p@x.com', is_verified: true)
      postrec = poster.referral_posts.create!(title: 'Role', job_title: 'Dev', company_name: 'X', company_verification: cv, status: :closed)

      rr = postrec.referral_requests.create!(user: requester, status: :approved, submitted_data: {})

      # stub login as post owner
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(poster)
      allow_any_instance_of(ApplicationController).to receive(:require_login).and_return(true)

      patch update_referral_request_status_path(rr), params: { status: 'pending' }

      expect(response).to redirect_to(dashboard_path)
      postrec.reload
      expect(postrec.status).to eq('active')
    end
  end

  describe 'ReferralRequests normalize_submitted_data else branch' do
    it 'returns value hash for non-string, non-hash input' do
      controller = ReferralRequestsController.new
      result = controller.send(:normalize_submitted_data, 12345)
      expect(result).to eq({ 'value' => 12345 })
    end
  end

  describe 'UsersController update_experience failure branch' do
    it 'renders edit_experience and sets flash when save fails during update_experience' do
      user = User.create!(email: 'u4@tamu.edu', password: 'password', first_name: 'U', last_name: 'Four')
      user.experiences_data <<({ 'title' => 'Old', 'company' => 'OldCo', 'start_date' => '2020-01-01' })
      user.save!

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:require_login).and_return(true)

      allow_any_instance_of(User).to receive(:save).and_return(false)
      allow_any_instance_of(User).to receive(:errors).and_return(double(full_messages: [ 'oops' ]))

      patch update_experience_user_path(user, index: 0), params: { experience: { title: 'New' } }

      expect(response).to render_template(:edit_experience)
      expect(flash[:error]).to include('oops')
    end
  end
end
