
# Raised when there is an attempt of add a category to a relation that is full
class UbiquoCategories::LimitError < StandardError; end

# Raised when there is an assignation to a category set that does not exist
class UbiquoCategories::SetNotFoundError < StandardError; end
