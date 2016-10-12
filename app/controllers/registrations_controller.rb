# added for Imago
# See http://stackoverflow.com/questions/6734323/how-do-i-remove-the-devise-route-to-sign-up
class RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to root_path
  end

  def create
    redirect_to root_path
  end
end
