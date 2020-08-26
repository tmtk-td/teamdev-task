class PassOwnerMailer < ApplicationMailer
  def pass_owner_mail(assign, team)
    @email = assign.user.email
    @team = team.name
    mail to: @email, subject: I18n.t('views.messages.become_the_leader')
  end
end