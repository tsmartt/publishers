# Used to register a publisher with > 5 channels async
module Promo
  class RegisterPublisherForPromoJob < ApplicationJob
    include PromosHelper
    queue_as :default

    def perform(publisher:)
      return unless publisher.feature_flags[UserFeatureFlags::REFERRAL_ENABLED_OVERRIDE]
      Rails.logger.info("Registering publisher #{publisher.id} for promo async.")

      if Promo::PublisherChannelsRegistrar.new(publisher: publisher).perform
        promo_enabled_channels = publisher.channels.joins(:promo_registration)
        PromoMailer.promo_activated_2018q1_verified(publisher, promo_enabled_channels).deliver
      else
        Rails.logger.warn("Failed to register publisher #{publisher.id} with promo server async.")
      end
    end
  end
end
