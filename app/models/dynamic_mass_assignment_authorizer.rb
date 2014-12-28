# https://github.com/dei79/acts-as-taggable-on-dynamic/blob/master/lib/acts_as_taggable_on_dynamic/dynamic_mass_assignment_authorizer.rb
class DynamicMassAssignmentAuthorizer
  def initialize(model, orgAuthorizer)
    @model = model
    @orgAuthorizer = orgAuthorizer
  end
  
  def deny?(key)
    if (@model.dynamic_tag_context_attribute?(key) || @model.tag_list_attribute?(key))
      false
    else
      @orgAuthorizer.deny?(key)
    end
  end
end