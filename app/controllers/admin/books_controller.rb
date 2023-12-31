class Admin::BooksController < Admin::BaseController
  before_action :get_book,
                only: %i(show edit update destroy amend_edit amend)
  before_action :transform_params, only: :index

  def index
    books = Book.includes_info.available

    q = params[:q]
    books = books.merge(Book.bquery(q)) if q

    s = params[:sort]
    books = s ? books.sort_on(s, params[:desc]) : books.newest

    @pagy, @books = pagy books
  end

  def show
    @tab_id = :book_detail
    render :tab_detail
  end

  def new
    @book = Book.new
    render :edit
  end

  def edit; end

  def create
    @book = Book.new book_params
    admin_save @book, :book,
               success_to: :amend_admin_book_path
  end

  def update
    return redirect_to amend_admin_book_path(@book) if params.key? :skip

    admin_update @book, book_params, :book,
                 success_to: :amend_admin_book_path
  end

  def amend_edit; end

  def amend
    return redirect_to admin_book_path(@book) if params.key? :skip

    update_book

    if @book.errors.any?
      respond_to_form_fail @book
    else
      flash[:success] = t "admin.notif.update_success", name: t("books._name")
      redirect_to [:admin, @book]
    end
  end

  def destroy
    if @book.borrowed_count.positive?
      flash.now[:error] = t "admin.notif.delete_book_fail_borrowed"
      return application_notify
    end
    destroy_method = @book.update is_active: false
    admin_destroy @book, :book, destroy_method:
  end

  private
  def get_book
    @book = Book.find_by id: params[:id]
    return if @book

    flash[:error] = t "admin.notif.item_not_found", name: t("books._name")
    redirect_to admin_books_path
  end

  def update_book
    publisher_id = params.dig(:book, :publisher)
    author_ids = params.dig(:book, :authors)
    genre_ids = params.dig(:book, :genres)

    @book.transaction do
      @book.update(publisher_id:) if publisher_id
      @book.update_relation_with_ids(:author, author_ids) if author_ids
      @book.update_relation_with_ids(:genre, genre_ids) if genre_ids
    end
  end

  def book_params
    params.require(:book).permit :title, :description, :amount,
                                 :isbn, :publish_date, :image
  end

  def relation_params
    params.require(:book).permit :publisher, :authors, :genres
  end

  def transform_params
    permit_sorts = {
      publisher: "publishers.name",
      title: "books.title",
      publish_date: "books.publish_date",
      remain: "books.amount - books.borrowed_count",
      author: "authors.name",
      genre: "genres.name"
    }
    s = params[:sort]&.downcase&.to_sym
    params[:sort] = permit_sorts[s]
  end
end
