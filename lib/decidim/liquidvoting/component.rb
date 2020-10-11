# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:liquidvoting) do |component|
  component.engine = Decidim::Liquidvoting::Engine
  component.admin_engine = Decidim::Liquidvoting::AdminEngine
  component.icon = "decidim/liquidvoting/icon.svg"

  component.permissions_class_name = "Decidim::Liquidvoting::Permissions"

  # component.settings(:global) do |settings|
  #   settings.attribute :announcement, type: :text, translated: true, editor: true
  # end

  # component.settings(:step) do |settings|
  #   settings.attribute :announcement, type: :text, translated: true, editor: true
  # end
end
