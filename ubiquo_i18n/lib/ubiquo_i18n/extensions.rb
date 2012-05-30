module UbiquoI18n::Extensions; end
loader = Ubiquo::Extensions::Loader

ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::ActiveRecord)
ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::NestedAttributes)
ActiveRecord::Relation.send(:include, UbiquoI18n::Extensions::Relation)
ActiveRecord::Reflection::AssociationReflection.send(:include, UbiquoI18n::Extensions::AssociationReflection)
ActiveRecord::Associations::AssociationScope.send(:include, UbiquoI18n::Extensions::AssociationScope)
ActiveRecord::Associations::Association.send(:include, UbiquoI18n::Extensions::Association)
ActiveRecord::Associations::BelongsToAssociation.send(:include, UbiquoI18n::Extensions::Association)
ActiveRecord::Associations::CollectionAssociation.send(:include, UbiquoI18n::Extensions::CollectionAssociation)
ActiveRecord::Associations::Builder.send(:include, UbiquoI18n::Extensions::AssociationsBuilder)
loader.append_include(:UbiquoController, UbiquoI18n::Extensions::LocaleChanger)
loader.append_include(:UbiquoController, UbiquoI18n::Extensions::LocaleUrlBuilder)
loader.append_helper(:UbiquoController, UbiquoI18n::Extensions::Helpers)
loader.append_include(:ApplicationController, UbiquoI18n::Extensions::LocaleUseFallbacks::Application)
loader.append_include(:UbiquoController, UbiquoI18n::Extensions::LocaleUseFallbacks::Ubiquo)

ActionController::TestCase.send(:include, UbiquoI18n::Extensions::TestCase) if Rails.env.test?
