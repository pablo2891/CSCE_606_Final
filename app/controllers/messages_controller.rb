class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_to conversation_path(@conversation), notice: "Message sent."
    else
      @messages = @conversation.messages.order(created_at: :asc)
      render "conversations/show", alert: "Failed to send message."
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
    unless [ @conversation.sender_id, @conversation.recipient_id ].include?(current_user.id)
      redirect_to conversations_path, alert: "Unauthorized"
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
