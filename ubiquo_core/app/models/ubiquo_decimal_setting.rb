class UbiquoDecimalSetting < UbiquoSetting

  serialize :value, Float
  validates :value, :numericality => { :only_integer => false, :allow_nil => true }

end
