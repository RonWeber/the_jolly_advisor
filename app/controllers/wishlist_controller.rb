class WishlistController < ApplicationController
  before_action :authenticate_user!
  before_action :find_wishlist_item, except: [:index]

  # GET /wishlist
  def index
    @wishlist = current_user.wishlist.includes(course: :course_instances).order(:course_id)
  end

  # POST /wishlist
  def add_course
    respond_to do |format|
      if @wishlist_item.save
        flash[:notice] = 'Course successfully saved to your wishlist'
        format.html { redirect_to params[:url] || wishlist_path }
      else
        flash[:notice] = 'An error occurred adding the course to your wishlist'
        format.html { redirect_to params[:url] || wishlist_path }
      end
    end
  end

  # PUT /wishlist
  def update
    respond_to do |format|
      @wishlist_item.update(wishlist_item_params)
      format.html { redirect_to wishlist_path }
    end
  end

  # DELETE /wishlist
  def remove_course
    respond_to do |format|
      if @wishlist_item.destroy
        flash[:notice] = 'Course successfully removed from your wishlist'
        format.html { redirect_to params[:url] || wishlist_path }
      else
        flash[:notice] =
          'An error occurred while attempting to remove the course from your wishlist'
        format.html { redirect_to params[:url] || wishlist_path }
      end
    end
  end

  private

  def find_wishlist_item
    # If the user used the autocomplete, the :course_id param will have a
    # value. If they did, use that course id. Otherwise pass the :course_title
    # search to the Course search method and just grab the first result. If we
    # still don't have a legit course id, redirect to the wishlist page.
    course_id =
      if params[:course_id].present?
        params[:course_id]
      else
        Course.search(params[:course_title]).first.try(:id)
      end
    redirect_to wishlist_path if course_id.nil?

    @wishlist_item =
      WishlistItem.where(user: current_user, course_id: course_id).first_or_initialize
  end

  def wishlist_item_params
    params.require(:wishlist_item).permit(:notify)
  end
end
