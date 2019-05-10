module FlashHelper
  def bulma_flash_class
    @@flash_classes = Hash.new('').merge({
      # Not used: is-primary, is-link, no class. is-white is-light is-text is-black ?
      'success' => 'is-success',
      'error'   => 'is-danger',
      'notice'  => 'is-link',
      'info'    => 'is-info',
      'alert'   => 'is-dark',
      'warning' => 'is-warning',
    }).freeze
  end

  def add_flash key, value=nil
    if key.is_a? Hash
      hash = key
      hash.each {|k,v| (flash[k.to_sym] ||= Set.new) << v}
      #if message.to_s != '' && !flash[message_type.to_sym]&.include?(message)
    else
      return if key.nil? || value.nil?
      (flash[key.to_sym] ||= Set.new) << value
    end
  end

  # maddish multi-flash solution
  def add_flashs kv={}, notice: nil, warning: nil, success: nil, failure: nil, info: nil
    flash_adds = {notice: notice, warning: warning,
     success: success, failure: failure,
     info: info}.select {|mt,m| !m.blank?}

    flash_adds.each do |message_type, message|
      if !flash[message_type.to_sym]&.include?(message)
        (flash[message_type.to_sym] ||= []) << message
      end
    end

    if !kv.empty?
      kv.each do |message_type, message|
        if message.to_s != '' && !flash[message_type.to_sym]&.include?(message)
          (flash[message_type.to_sym] ||= []) << message
        end
      end
    end
  end
end
