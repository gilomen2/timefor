class Admin::ContactsController < ApplicationController
  def index
    @contacts = Contact.all
  end

  def show
    @contacts = Contact.find
  end

  def new
    @contact = Contact.new
    @user = current_user
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.user = current_user

    if @contact.save
      flash[:notice] = "Your new Contact was saved."
      redirect_to admin_contacts_path
    else
      flash[:error] = "There was a problem saving the Wiki. Please try again."
      redirect_to new_admin_contact_path
    end
  end

  def edit
    @contact = Contact.find(params[:id])
    @user = current_user
  end

  def update
    @contact = Contact.find(params[:id])

    if @contact.update_attributes(contact_params)
      flash[:notice] = "Your Contact has been updated."
      redirect_to admin_contacts_path
    else
      flash[:error] = "There was a problem saving the Contact. Please try again."
      redirect_to edit_admin_contact_path
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    if @contact.destroy
      flash[:notice] = "Contact successfully deleted."
      redirect_to admin_contacts_path
    else
      flash[:error] = "There was a problem deleting the Contact. Please try again."
      render :show
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :phone)
  end
end
