class Comment < ActiveRecord::Base

	belongs_to :user, inverse_of: :comments
	belongs_to :commentable, polymorphic: true

	belongs_to :parent, class_name: "Comment"
	has_many :replies, foreign_key: "parent_id", class_name: "Comment"
  has_many :recent_replies, -> { order('id DESC').limit(3) }, foreign_key: "parent_id", class_name: "Comment"

	default_scope -> { order('created_at ASC') }
	scope :recent, -> { reorder('created_at DESC').limit(3).sort_by(&:created_at).reverse }

  def as_json(options = {})
    return super unless options[:custom]
    
    {
      user_name: user.username,
      avatar_url: user.user_thumb_url,
      is_tastemaker: self.user.is_tastemaker,
      message: self.body,
      created_at: self.created_at.to_i
    }
  end
end

