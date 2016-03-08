class Admin::ContactsController < ApplicationController
  def index
    @user = current_user
    @contacts = policy_scope(Contact).sort_by { |obj| obj.created_at }
    @contact = Contact.new
    authorize Contact
  end

  def show
    @contact = Contact.find(params[:id])
    authorize @contact
    render :json => @contact
  end

  def new
    @contact = Contact.new
    @user = current_user
    @title = "Add Contact"
    authorize @contact
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.user = current_user
    authorize @contact
    respond_to do |format|
      if @contact.save
        format.html { redirect_to polymorphic_path([:admin, @contact]), notice: 'Contact was successfully created.' }
        format.json { render action: 'add', status: :created, location: [:admin, @contact] }
        format.js   { render action: 'add', status: :created, location: [:admin, @contact] }
      else
        format.json { render action: 'error' }
        format.js   { render action: 'error' }
      end
    end
  end

  def clone
    @contact = Contact.find(params[:id])
    @contact = Contact.new(@contact.attributes)
    @title = "Copy Contact"
    render :new
  end


  def destroy
    @contact = Contact.find(params[:id])
    authorize @contact
    if @contact.destroy
      flash.now[:success] = "Contact successfully deleted."
    else
      flash.now[:error] = "There was a problem deleting the Contact. Please try again."
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
