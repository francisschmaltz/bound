# == Schema Information
#
# Table name: api_tokens
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  token        :string(255)
#  last_used_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class APIToken < ApplicationRecord

  validates :name, :presence => true

  random_string :token, :type => :uuid

end
