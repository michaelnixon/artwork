class Artwork < ActiveRecord::Base
  belongs_to :artist
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  acts_as_taggable  
  has_attached_file :asset, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :asset, :content_type => /\Aimage\/.*\Z/
  
  # uses SQL like to determine if the name or preview text matches the search term
  def self.search(search)
    if search
      where("name like ? or description like ?", "%#{search}%", "%#{search}%") 
    else
      all
    end
  end  
  ##
  # Return an array of context names which are valid for the given model type
  #
  # Example:
  # self.tag_context_list => ['tags']
  # https://github.com/dei79/acts-as-taggable-on-dynamic/blob/master/lib/acts_as_taggable_on_dynamic/utils.rb
  #
  def tag_context_list
    ActsAsTaggableOn::Tagging.where("taggable_type = '#{self.class.name}'").select(:context).uniq.map(&:context)
  end
  
  def self.tag_context_list
    ActsAsTaggableOn::Tagging.where("taggable_type = '#{self.name}'").select(:context).uniq.map(&:context)    
  end
  
  # the following instance methods are from https://github.com/dei79/acts-as-taggable-on-dynamic/blob/master/lib/acts_as_taggable_on_dynamic/dynamic_tag_context_attributes.rb
  ##
  # Returns a text string which returns generates the list attribute given by the context name for taggings
  #
  # Example:
  # self.dynamic_tag_context_attribute("skills") => "dynamic_tag_context_skill_list"
  #
  def dynamic_tag_context_attribute(context)
    "dynamic_tag_context_#{context.singularize}_list"
  end
  
  def dynamic_tag_context_attribute_template()
    "dynamic_tag_context_{{context}}_list"
  end
  
  def dynamic_tag_context_label_template()
    "{{context}}"
  end
  ##
  # Validates if the given attribute is a dynamic context tag
  #
  def dynamic_tag_context_attribute?(attribute)
    (attribute.to_s.start_with?('dynamic_tag_context_') && attribute.to_s.ends_with?('_list'))
  end
  ##
  # Returns the context of a give attributes name
  #
  def dynamic_tag_context_from_attribute(attribute)
    attribute.to_s.sub('dynamic_tag_context_', '').chomp('_list').pluralize
  end
  ##
  # Validates if the given attribute is a tag list attribute
  def tag_list_attribute?(attribute)
    attribute.to_s.ends_with?('_list')
  end
  ##
  # Returns the content of a given tag list
  #
  def tag_list_content_on(context)
    # if (self.is_auto_tag_ownership_enabled?)
    #   self.owner_tags_on(self.tag_owner, context).map(&:to_s).join(',').chomp(',')
    # else
      self.tags_on(context).map(&:to_s).join(',').chomp(',')
    # end
  end
  ##
  # Handles all read and write operations to a dynamic tag context
  #
  def method_missing(method_name, *args, &block)
    attribute = method_name.to_s.chomp('=')
    if ( dynamic_tag_context_attribute?(attribute) || tag_list_attribute?(attribute))
      context = dynamic_tag_context_from_attribute(attribute).to_sym
      if (method_name.to_s.ends_with?("="))
        self.write_tag_list_on(context, args.join(',').chomp(','))
      else
        self.tag_list_content_on(context)
      end
    else
      super
    end
  end
  ##
  # Validates if the requested method a supported method
  #
  def respond_to?(method_name, include_private = false)
    dynamic_tag_context_attribute?(method_name.to_s.chomp("=")) || tag_list_attribute?(method_name.to_s.chomp("=")) || super
  end
  ##
  # Returns the mass assignment authorizer
  #
  def mass_assignment_authorizer(role)
    DynamicMassAssignmentAuthorizer.new(self, super(role))
  end
  ##
  # Handles the write request
  def write_tag_list_on(context, tags)
    # if (self.is_auto_tag_ownership_enabled?)
    #   self.tag_owner.tag(self, :with => tags, :on => context, :skip_save => true)
    # else
      self.set_tag_list_on(context, tags)
    # end
  end
  
  def self.import(file)
    CSV.foreach(file, headers: true, skip_blanks: true) do |row|
      owner_email = row['owner_email']
      owner_email = "sdipaola@sfu.ca" if owner_email.blank?
      
      # unless they already exist, create the account and send them the email
      unless owner = User.find_by_email(owner_email)
        random_password = Array.new(10).map { (65 + rand(58)).chr }.join
        random_password += "1$" # stupid kludge to make it accepted by the acceptable password regex
        owner = User.create(email: owner_email, password: random_password, password_confirmation: random_password)
        Mailer.forgot_password(owner, random_password).deliver
      end            
          
      artist_name = row['artist_slug'].strip.gsub(/-/,'_').humanize.titleize
      unless artist_name.empty?
        artist = Artist.find_by_name(artist_name) || Artist.create(name: artist_name)
      end     

      if row['name'].blank?
        artwork_name = "Painting by #{artist_name}"
      else
      artwork_name = row['name'].strip        
      end
      
      artwork = Artwork.find_by_name(artwork_name) || Artwork.create(name: artwork_name)
      artwork.name = artwork_name
      artwork.completion_date = row['date']
      artwork.artist = artist
      artwork.owner = owner
            
      artwork.save!
            
      unless row['keywords'].blank?
        keywords = row['keywords']
        keywords[0]=''
        keywords[-1]=''
        all_keywords = keywords.split(',  ')
        keys = all_keywords.join(',')
        artwork.set_tag_list_on("keywords", keys)
      end
      #dimensions
      #gallery info
      #artist
      #description
      
      ##genre
      ##style
      ##technique
      ##keywords     
      
      artwork.genre_list = row['genre']
      artwork.style_list = row['style']
      artwork.technique_list = row['technique'] unless row['technique'].blank?
            
      unless row['image_url'].blank? 
        begin #todo ensure File.open uses a url
          # asset = Asset.new(:file => File.open(row['image_url']))
          # asset.attachable = track
          # asset.save!
#          artwork.asset = asset
          artwork.asset = URI.parse(row['image_url'])
        rescue
          puts "failed on #{row['image_url']}"
        end
      end
      artwork.save!

    end
  end
end
