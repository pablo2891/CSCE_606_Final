class ConversationsController < ApplicationController
  before_action :require_login
  before_action :set_conversation, only: %i[show destroy]

  def index
    # all conversations involving current_user
    @conversations = Conversation.where("sender_id = :id OR recipient_id = :id", id: current_user.id)
                                 .includes(:messages, :sender, :recipient)
                                 .order(updated_at: :desc)
  end

  def show
    # mark messages sent to current_user as read
    @messages = @conversation.messages.order(created_at: :asc)
    @messages.where.not(user_id: current_user.id).update_all(read: true)
    @message = Message.new
  end

  def create
    # expects params: recipient_id, subject (optional), body (optional)
    recipient = User.find(params.require(:recipient_id))
    subject   = params[:subject]
    @conversation = Conversation.find_or_create_between(current_user, recipient, subject: subject)

    if params[:body].present?
      @conversation.messages.create!(user: current_user, body: params[:body])
    end

    redirect_to conversation_path(@conversation)
  end

  def destroy
    # allow only participants to destroy (soft delete by removing record)
    unless [ @conversation.sender_id, @conversation.recipient_id ].include?(current_user.id)
      redirect_to conversations_path, alert: "Unauthorized"
      return
    end

    @conversation.destroy
    redirect_to conversations_path, notice: "Conversation deleted"
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
    unless [ @conversation.sender_id, @conversation.recipient_id ].include?(current_user.id)
      redirect_to conversations_path, alert: "Unauthorized"
    end
  end
end
