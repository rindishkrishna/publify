# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  require "open-uri"
  require "time"
  require "rexml/document"

  def index
    today = Time.zone.now.strftime("%Y-%m-%d 00:00")

    # Since last visit
    last_sign_in = current_user.last_sign_in_at
    @newposts_count = Article.published_since(last_sign_in).count
    @newcomments_count = Feedback.created_since(last_sign_in).count

    # Today
    @statposts = Article.published.where("published_at > ?", today).count
    @statsdrafts = Article.drafts.where("created_at > ?", today).count
    @statspages = Page.where("published_at > ?", today).count
    @statuses = Note.where("published_at > ?", today).count
    @statuserposts = Article.published.where("published_at > ?", today).
      where(user_id: current_user.id).count
    @statcomments = Comment.where("created_at > ?", today).count
    @presumedspam = Comment.presumed_spam.where("created_at > ?", today).count
    @confirmed = Comment.ham.where("created_at > ?", today).count
    @unconfirmed = Comment.unconfirmed.where("created_at > ?", today).count

    @comments = Comment.last_published
    @drafts = Article.drafts.where(user_id: current_user.id).limit(5)

    @statspam = Comment.spam.count
  end


  def index_in_pipeline
    today = Time.zone.now.strftime("%Y-%m-%d 00:00")

    # Since last visit
    last_sign_in = current_user.last_sign_in_at
    @newposts_count = Article.published_since(last_sign_in).count
    @newcomments_count = Feedback.created_since(last_sign_in).count

    # Today
    @statposts = Article.published.where("published_at > ?", today).count
    @statsdrafts = Article.drafts.where("created_at > ?", today).count
    @statspages = Page.where("published_at > ?", today).count
    @statuses = Note.where("published_at > ?", today).count
    @statuserposts = Article.published.where("published_at > ?", today).
      where(user_id: current_user.id).count
    @statcomments = Comment.where("created_at > ?", today).count
    @presumedspam = Comment.presumed_spam.where("created_at > ?", today).count
    @confirmed = Comment.ham.where("created_at > ?", today).count
    @unconfirmed = Comment.unconfirmed.where("created_at > ?", today).count

    @comments = Comment.last_published.load_in_pipeline
    @drafts = Article.drafts.where(user_id: current_user.id).limit(5).load_in_pipeline

    @statspam = Comment.spam.count
  end

  def index_on_steroids
    today = Time.zone.now.strftime("%Y-%m-%d 00:00")

    # Since last visit
    last_sign_in = current_user.last_sign_in_at
    @newposts_count = Article.published_since(last_sign_in).count
    @newcomments_count = Feedback.created_since(last_sign_in).count

    # Today
    @statposts = Article.published.where("published_at > ?", today)
    @statsdrafts = Article.drafts.where("created_at > ?", today)
    @statspages = Page.where("published_at > ?", today)
    @statuses = Note.where("published_at > ?", today)
    @statuserposts = Article.published.where("published_at > ?", today).
      where(user_id: current_user.id)
    @statcomments = Comment.where("created_at > ?", today)
    @presumedspam = Comment.presumed_spam.where("created_at > ?", today)
    @confirmed = Comment.ham.where("created_at > ?", today)
    @unconfirmed = Comment.unconfirmed.where("created_at > ?", today)

    @comments = Comment.last_published
    @drafts = Article.drafts.where(user_id: current_user.id).limit(5)

    @statspam = Comment.spam.count
  end

  def index_on_steroids_in_pipeline
    today = Time.zone.now.strftime("%Y-%m-%d 00:00")

    # Since last visit
    last_sign_in = current_user.last_sign_in_at
    @newposts_count = Article.published_since(last_sign_in).count
    @newcomments_count = Feedback.created_since(last_sign_in).count

    # Today
    @statposts = Article.published.where("published_at > ?", today).load_in_pipeline
    @statsdrafts = Article.drafts.where("created_at > ?", today).load_in_pipeline
    @statspages = Page.where("published_at > ?", today).load_in_pipeline
    @statuses = Note.where("published_at > ?", today).load_in_pipeline
    @statuserposts = Article.published.where("published_at > ?", today).
      where(user_id: current_user.id).load_in_pipeline
    @statcomments = Comment.where("created_at > ?", today).load_in_pipeline
    @presumedspam = Comment.presumed_spam.where("created_at > ?", today).load_in_pipeline
    @confirmed = Comment.ham.where("created_at > ?", today).load_in_pipeline
    @unconfirmed = Comment.unconfirmed.where("created_at > ?", today).load_in_pipeline

    @comments = Comment.last_published.load_in_pipeline
    @drafts = Article.drafts.where(user_id: current_user.id).limit(5).load_in_pipeline

    @statspam = Comment.spam.count
  end
end
