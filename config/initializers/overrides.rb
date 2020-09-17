# frozen_string_literal: true

Rails.application.config.to_prepare do
  Dir.glob(Rails.root + "app/overrides/**/*.rb").each do |c|
    require_dependency(c)
  end
end
