class Settings
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :legacy_uri
  attribute :production_url

  def save
    Setting.find_or_initialize_by(key: 'legacy_uri').update!(value: legacy_uri)
    Setting.find_or_initialize_by(key: 'production_url').update!(value: production_url)
  end


  def self.load
    legacy_uri = Setting.find_or_create_by(key: 'legacy_uri').value
    production_url = Setting.find_or_create_by(key: 'production_url').value
    Settings.new(
      legacy_uri: legacy_uri,
      production_url: production_url
    )
  end
end
