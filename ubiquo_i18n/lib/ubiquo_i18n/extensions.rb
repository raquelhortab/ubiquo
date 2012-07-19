module UbiquoI18n::Extensions; end

ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::ActiveRecord)
ActiveRecord::Base.send(:include, UbiquoI18n::Extensions::NestedAttributes)
ActiveRecord::Relation.send(:include, UbiquoI18n::Extensions::Relation)
ActiveRecord::Reflection::AssociationReflection.send(:include, UbiquoI18n::Extensions::AssociationReflection)
ActiveRecord::Associations::AssociationScope.send(:include, UbiquoI18n::Extensions::AssociationScope)
ActiveRecord::Associations::Association.send(:include, UbiquoI18n::Extensions::Association)
ActiveRecord::Associations::BelongsToAssociation.send(:include, UbiquoI18n::Extensions::Association)
ActiveRecord::Associations::CollectionAssociation.send(:include, UbiquoI18n::Extensions::CollectionAssociation)
ActiveRecord::Associations::Builder.send(:include, UbiquoI18n::Extensions::AssociationsBuilder)
:UbiquoController.include! UbiquoI18n::Extensions::LocaleChanger
:UbiquoController.include! UbiquoI18n::Extensions::LocaleUrlBuilder
:UbiquoController.helper! UbiquoI18n::Extensions::Helpers
:ApplicationController.include! UbiquoI18n::Extensions::LocaleUseFallbacks::Application
:UbiquoController.include! UbiquoI18n::Extensions::LocaleUseFallbacks::Ubiquo

ActionController::TestCase.send(:include, UbiquoI18n::Extensions::TestCase) if Rails.env.test?
