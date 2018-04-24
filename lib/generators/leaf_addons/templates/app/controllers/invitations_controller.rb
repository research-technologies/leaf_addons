# frozen_string_literal: true

class InvitationsController < Devise::InvitationsController
  # TODO: add test
  before_action :ensure_admin!, only: [:new, :create, :destroy]

  private

    def ensure_admin!
      authorize! :read, :admin_dashboard
    end
end
