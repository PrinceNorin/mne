class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :danger

  before_action :set_locale
  before_action :permitted_params, if: :devise_controller?
  before_action :set_paper_trail_whodunnit, unless: :devise_controller?

  protected

  def set_locale
    if params[:locale]
      cookies[:locale] = params[:locale]
      I18n.locale = params[:locale].to_sym
      redirect_to request.path.gsub(/[?&]locale=.*/, '')
    else
      I18n.locale = (cookies[:locale] || I18n.default_locale).to_sym
    end
  end

  def permitted_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
