class Mailer < ActionMailer::Base
  default from: "admin@foo.bar"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.mailer.forgot_password.subject
  #
  def forgot_password(user, new_password)
    @email = user.email
    @alias = user.alias
    @new_password = new_password
    @login_url = "http://localhost:3000/sessions/new"
    mail to: @email, subject: "New password for artwork database"
  end
end
