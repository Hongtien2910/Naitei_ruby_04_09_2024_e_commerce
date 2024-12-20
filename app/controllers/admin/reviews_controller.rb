class Admin::ReviewsController < Admin::AdminController
  include Pagy::Backend
  before_action :find_review, only: %i(show destroy)

  def index
    @pagy, @reviews = pagy search_reviews
  end

  def show
    @reviews = Review.where(product_id: @review.product_id)
  end

  def destroy
    ActiveRecord::Base.transaction do
      @review.destroy!
      flash[:success] = t "admin.reviews_admin.destroy.success"
      redirect_to admin_reviews_path(@product)
    end
  rescue ActiveRecord::RecordNotDestroyed
    flash[:alert] = t "admin.reviews_admin.destroy.failure"
    redirect_to admin_reviews_path(@product)
  end

  private

  def find_review
    @review = Review.find_by(id: params[:id])
    return if @review

    flash[:alert] = t "admin.reviews_admin.not_found"
    redirect_to admin_reviews_path(@product)
  end

  def search_reviews
    reviews = Review.all
    reviews = filter_reviews_by_query(reviews)
    reviews = filter_reviews_by_rating(reviews)
    sort_reviews(reviews)
  end

  def filter_reviews_by_query reviews
    query = params[:query]
    if query.present?
      reviews.joins(:user, :product).where(
        "LOWER(users.user_name) LIKE LOWER(:query) OR
       LOWER(products.name) LIKE LOWER(:query)",
        query: "%#{query.downcase}%"
      )
    else
      reviews
    end
  end

  def filter_reviews_by_rating reviews
    rating = params[:rating]
    if rating.present?
      reviews.by_rating(rating)
    else
      reviews
    end
  end

  def sort_reviews reviews
    if params[:sort].blank?
      reviews
    else
      reviews.public_send("sort_by_#{params[:sort]}", params[:direction])
    end
  end
end
