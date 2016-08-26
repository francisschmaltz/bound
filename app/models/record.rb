# == Schema Information
#
# Table name: records
#
#  id         :integer          not null, primary key
#  zone_id    :integer
#  name       :string(255)
#  type       :string(255)
#  data       :string(255)
#  ttl        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Record < ApplicationRecord

  attribute :type, RecordTypeType.new

  belongs_to :zone, :touch => true

  validates :name, :hostname => true
  validates :type, :presence => true
  validates :ttl, :numericality => {:only_integer => true, :allow_blank => true}
  validates :data, :presence => true
  validate :validate_data

  def bind_line
    String.new.tap do |s|
      s << (self.name.blank? ? "@" : self.name).to_s.ljust(Zone::ZF_NAME_SPACE, ' ') + " "
      s << self.ttl.to_s.ljust(Zone::ZF_TTL_SPACE, ' ') + " " if self.ttl
      s << "IN".ljust(Zone::ZF_CLASS_SPACE, ' ')
      s << type.type.ljust(Zone::ZF_TYPE_SPACE, ' ') + " "
      s << type.prepare_for_bind(self.data)
    end
  end

  def validate_data
    if self.type && self.data.present?
      type_errors = []
      self.type.validate(self.data, type_errors)
      type_errors.each do |error|
        self.errors.add :base, error
      end
    end
  end

end

