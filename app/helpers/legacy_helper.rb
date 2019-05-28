module LegacyHelper
  def legacy_web_url seminar, settings=nil
    if settings == nil
      settings = Settings.load
    end

    "#{settings.legacy_web_url}/seminar/seminar/edit/#{seminar.uuid}"
  end
end
