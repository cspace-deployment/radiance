module GlobalAlerts
  class Engine < ::Rails::Engine
    isolate_namespace GlobalAlerts

    config.cache = nil #defaults to Rails.cache
    config.application_name = nil
    config_url = "https://raw.githubusercontent.com/cspace-deployment/radiance/master/extras/pahma_alerts.yaml"
    config.url = config_url

    initializer('global_alerts_default') do |app|
      config.application_name ||= app.class.parent_name.underscore
    end
  end
end
