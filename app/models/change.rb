# == Schema Information
#
# Table name: changes
#
#  id             :integer          not null, primary key
#  zone_id        :integer
#  user_id        :integer
#  event          :string(255)
#  name           :string(255)
#  attribute_name :string(255)
#  old_value      :string(4096)
#  new_value      :string(4096)
#  published_at   :datetime
#  serial         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Change < ApplicationRecord

  belongs_to :zone, :optional => true
  belongs_to :user, :optional => true

  scope :pending, -> { where(:published_at => nil) }

  def description
    case event
    when 'ZoneAdded'
      "Zone [#{name}] added"
    when 'ZoneDeleted'
      "Zone [#{name}] deleted"
    when "ZoneAttributeChanged"
      "Zone [#{name}]'s [#{attribute_name}] was changed to [#{new_value}]"
    when "RecordAdded"
      "Record [#{name}] was added"
    when "RecordDeleted"
      "Record [#{name}] was deleted"
    when "RecordRenamed"
      "Record [#{old_value}] was renamed to [#{new_value}]"
    when "RecordDataChanged"
      "Record [#{name}] was changed to [#{new_value}] (previously #{old_value})"
    when "RecordAttributeChanged"
      "Record [#{name}]'s [#{attribute_name}] was changed to [#{new_value}]"
    else
      event
    end
  end

end
