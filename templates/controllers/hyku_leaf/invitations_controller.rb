class InvitationsController < Devise::InvitationsController

  # TODO test
  before_action :ensure_admin!, :only => [:new, :create]

  private

  def ensure_admin!
    authorize! :read, :invitations
  end

  def deny_access(_exception)
    redirect_to main_app.root_url, alert: t('hyku.admin.flash.access_denied')
  end
end