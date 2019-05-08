class Settings
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :legacy_uri

  def save
    Setting.find_or_initialize_by(key: 'legacy_uri').update!(value: legacy_uri)
  end

  def update
    Setting.find_or_initialize_by(key: 'legacy_uri').update(value: legacy_uri).save
  end

  def self.load
    legacy_uri = Setting.find_or_create_by(key: 'legacy_uri').value
    Settings.new(
      legacy_uri: legacy_uri
    )
  end
end
