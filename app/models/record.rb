# == Schema Information
#
# Table name: records
#
#  id         :integer          not null, primary key
#  zone_id    :integer
#  name       :string(255)
#  type       :string(255)
#  data       :string(4096)
#  ttl        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Record < ApplicationRecord

  attribute :type, RecordTypeType.new

  belongs_to :zone, :touch => true

  validates :type, :presence => true
  validates :ttl, :numericality => {:only_integer => true, :allow_blank => true}
  validate :validate_data
  validate :validate_type

  before_validation { self.name = nil if self.name.to_s == "@" }

  before_save :serialize_form_data

  ATTRIBUTES_TO_TRACK = ['ttl']
  after_create { Change.create!(:zone => zone, :event => "RecordAdded", :name => description) }
  after_destroy { Change.create!(:zone => zone, :event => "RecordDeleted", :name => description) }
  after_update do
    if self.data_changed?
      Change.create!(:zone => zone, :event => "RecordDataChanged", :name => description, :old_value => self.data_was, :new_value => self.data)
    end

    if self.name_changed?
      Change.create!(:zone => zone, :event => "RecordRenamed", :name => description, :old_value => self.full_name_was, :new_value => self.full_name)
    end

    for key, (old_value, new_value) in self.changes
      next unless ATTRIBUTES_TO_TRACK.include?(key.to_s)
      Change.create!(:zone => zone, :event => "RecordAttributeChanged", :name => description, :attribute_name => key, :old_value => old_value, :new_value => new_value)
    end
  end

  def form_data
    @form_data ||= type.is_a?(Bound::RecordType) ? type.deserialize(data) : nil
  end

  def form_data=(value)
    @form_data = value
  end

  def serialize_form_data
    if @form_data
      self.data = type.is_a?(Bound::RecordType) ? type.serialize(@form_data) : nil
    end
  end

  def full_name
    if self.name.present?
      "#{name}.#{zone.name}"
    else
      zone.name
    end
  end

  def full_name_was
    if self.name_was.present?
      "#{name_was}.#{zone.name}"
    else
      zone.name
    end
  end

  def description
    "#{self.full_name} (#{self.type.type})"
  end

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
    if self.type.is_a?(Bound::RecordType) && @form_data
      type_errors = []
      self.type.validate(@form_data, type_errors)
      type_errors.each do |error|
        self.errors.add :base, error
      end
    end
  end

  def validate_type
    unless self.type.is_a?(Bound::RecordType)
      errors.add :type, "is not valid"
    end
  end

end

