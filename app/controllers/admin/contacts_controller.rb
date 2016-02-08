class Admin::ContactsController < ApplicationController
  def index
    @contacts = Contact.all
    @contact = Contact.new

  end

  def show
    @contact = Contact.find(params[:id])
    render :json => @contact
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
        format.json { render action: 'add', status: :created, location: [:admin, @contact] }
        # added:
        format.js   { render action: 'add', status: :created, location: [:admin, @contact] }
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
      redirect_to admin_contacts_path
      flash[:notice] = "Contact successfully edited."
    else
      redirect_to admin_contacts_path
      flash[:error] = "There was a problem editing the Contact. Please try again."
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    if @contact.destroy
      flash[:notice] = "Contact successfully deleted."
    else
      flash[:error] = "There was a problem deleting the Contact. Please try again."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :phone)
  end
end
