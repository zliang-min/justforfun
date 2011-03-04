class ArticlesController < ApplicationController

  before_filter :build_article

  def index
    @articles = Article.all
  end

  def show
  end

  def new
    @article = Article.new
  end

  def create
    if @article.save
      redirect_to @article, :notice => "Successfully created article."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @article.update_attributes(params[:article])
      redirect_to @article, :notice  => "Successfully updated article."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_url, :notice => "Successfully destroyed article."
  end

  private

  def build_article
    if id = params[:id] || params[:article][:id]
      @article = Article.find id
    end

    if params[:article]
      @article ||= Article.new
      @article.attributes = params[:article]
    end
  end
end
