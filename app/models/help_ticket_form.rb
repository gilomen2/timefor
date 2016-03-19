class HelpTicketForm < MailForm::Base
  attribute :message
  attribute :email
  attribute :name

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "TimeFor Help Ticket",
      :to => "gilomen2@gmail.com",
      :from => %("#{name}" <#{email}>)
    }
  end
end
