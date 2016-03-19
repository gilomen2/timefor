class Admin::HelpTicketFormController < ApplicationController
  def new
    @help_ticket_form = HelpTicketForm.new(help_ticket_params)
  end

  def create
    if current_user
      @user = current_user
      @help_ticket_form = HelpTicketForm.new(help_ticket_params)
      @help_ticket_form.name = @user.name
      @help_ticket_form.email = @user.email
      @help_ticket_form.request = request
      
      @help_ticket_form.deliver
      end
    end
  end

  private

  def help_ticket_params
    params.require(:help_ticket_form).permit(:message)
  end
end
