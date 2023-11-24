class AccountsController < ApplicationController
  def show
    @account = Account.find_by id: params[:id]
    return if @account

    flash[:warning] = t "account_not_found"
    redirect_to root_path
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new account_params
    if @account.save
      reset_session
      store_to_session @account
      flash[:success] = t "account_create_success"
      redirect_to root_path
    else
      render :new, status: :bad_request
    end
  end

  private

  def account_params
    params.require(:account).permit :email, :password, :password_confirmation,
                                    :username
  end
end