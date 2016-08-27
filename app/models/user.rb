# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  provider      :string(255)
#  uid           :string(255)
#  name          :string(255)
#  email_address :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invite_token  :string(255)
#

class User < ApplicationRecord

  validates :uid, :uniqueness => {:allow_blank => true, :scope => :provider}

  scope :activated, -> { where.not(:provider => nil) }
  scope :pending, -> { where(:provider => nil) }

  validates :email_address, :presence => {:unless => :provider}, :email_address => true

  random_string :invite_token, :type => :uuid, :unique => true

  def description
    name || email_address || "Anonymous"
  end

  def active?
    provider.present?
  end

  def pending?
    provider.nil?
  end

  def copy_attributes_from_auth_hash(auth_hash)
    self.provider = auth_hash.provider
    self.uid = auth_hash.uid
    self.name = auth_hash.info.name
    self.email_address = auth_hash.info.email
  end

  def copy_attributes_from_auth_hash!(auth_hash)
    copy_attributes_from_auth_hash(auth_hash)
    save!
  end

  def self.find_from_auth_hash(auth_hash)
    if user = where(:provider => auth_hash.provider, :uid => auth_hash.uid).first
      user.name = auth_hash.info.name
      user.email_address = auth_hash.info.email
      user.save!
      user
    elsif User.where(:provider => auth_hash.provider).count == 0
      create_user_from_auth_hash(auth_hash)
    else
      nil
    end
  end

  def self.create_user_from_auth_hash(auth_hash)
    user = User.new
    user.copy_attributes_from_auth_hash(auth_hash)
    user.save!
    user
  end

end
