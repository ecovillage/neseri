class Settings
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :legacy_db_uri
  attribute :legacy_web_url

  def save
    Setting.find_or_initialize_by(key: 'legacy_db_uri').update!(value: legacy_db_uri)
    Setting.find_or_initialize_by(key: 'legacy_web_url').update!(value: legacy_web_url)
  end

  # TODO if ever needed again, this helper would make saving/setting easier
  #def self.set key, value
  #  Setting.find_or_initialize_by(key: key).update(value: value).save
  #end

  def self.load
    legacy_db_uri = Setting.find_or_create_by(key: 'legacy_db_uri').value
    legacy_web_url = Setting.find_or_create_by(key: 'legacy_web_url').value
    Settings.new(
      legacy_db_uri: legacy_db_uri,
      legacy_web_url: legacy_web_url
    )
  end
end
