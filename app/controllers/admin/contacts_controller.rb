class Admin::ContactsController < ApplicationController
  def index
    @contacts = Contact.all
    @contact = Contact.new
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

    respond_to do |format|
      if @contact.save
        format.html { redirect_to polymorphic_path([:admin, @contact]), notice: 'Contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: [:admin, @contact] }
        # added:
        format.js   { render action: 'show', status: :created, location: [:admin, @contact] }
      else
        format.html { render action: 'new' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
        # added:
        format.js   { render json: @contact.errors, status: :unprocessable_entity }
      end
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
