module Thesis
  class Page < ActiveRecord::Base
    self.table_name = "pages"
    
    belongs_to :parent, class_name: "Page"
    has_many :subpages, class_name: "Page", foreign_key: "parent_id", order: "sort_order ASC"
    has_many :page_contents

    before_validation :update_slug
    after_save :update_subpage_slugs
    
    validates :slug, uniqueness: { message: "There's already a page like that. Change your page name." }, presence: true
    
    def update_slug
      self.slug = "/" << self.name.parameterize
      self.slug = "#{parent.slug.to_s}#{self.slug.to_s}" if parent
    end
    
    def update_subpage_slugs
      subpages.each(&:save) if slug_changed?
    end
    
    def content(name, content_type = :html)
      pc = find_or_create_page_content(name, content_type)
      pc.render
    end
    
    def path
      self.slug
    end
    
  protected
    
    def find_or_create_page_content(name, content_type)
      page_content = self.page_contents.where(name: name).first_or_create do |pc|
        pc.content = "Edit This Area"
      end
      page_content.content_type = content_type
      page_content.save if page_content.changed?
      page_content
    end
  end
end
