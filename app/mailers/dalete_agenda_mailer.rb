class DaleteAgendaMailer < ApplicationMailer
  def delete_agenda_mail(agenda)
    @agenda = agenda
    mail to: @agenda.team.users.pluck(:email), subject: I18n.t('views.messages.delete_agenda')
  end
end
