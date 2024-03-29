module Sufia
  class WorkShowPresenter < ::CurationConcerns::WorkShowPresenter
    # delegate fields from Sufia::Works::Metadata to solr_document
    delegate :based_near, :related_url, :depositor, :identifier, :resource_type,
             :keyword, :itemtype, to: :solr_document

    delegate :collection_code, :catalog_number, :other_catalog_numbers, :continent, :country, :state_province, :county,
             :higher_geography, :locality, :decimal_latitude, :decimal_longitude, :scientific_name, :scientific_name_authorship,
             :kingdom, :phylum, :dwcclass, :order, :family, :genus, :specific_epithet,
             :infraspecific_epithet, :type_status, :basis_of_record, to: :solr_document

    # new for paleo
    delegate :bed, :dwcmember, :formation, :group, :latest_age_or_highest_stage, :earliest_age_or_lowest_stage, :latest_period_or_highest_system,
             :earliest_period_or_lowest_system, to: :solr_document

    #new for self-deposit
    delegate :institution_code, :occurrence_id, :country_code, :taxon_rank, :water_body, :location_remarks, :geodetic_datum, to: :solr_document

    def editor?
      current_ability.can?(:edit, solr_document)
    end

    def tweeter
      user = ::User.find_by_user_key(depositor)
      if user.try(:twitter_handle).present?
        "@#{user.twitter_handle}"
      else
        I18n.translate('sufia.product_twitter_handle')
      end
    end

    def display_feature_link?
      user_can_feature_works? && solr_document.public? && FeaturedWork.can_create_another? && !featured?
    end

    def display_unfeature_link?
      user_can_feature_works? && solr_document.public? && featured?
    end

    def stats_path
      Sufia::Engine.routes.url_helpers.stats_work_path(self)
    end

    private

    def featured?
      if @featured.nil?
        @featured = FeaturedWork.where(work_id: solr_document.id).exists?
      end
      @featured
    end

    def user_can_feature_works?
      current_ability.can?(:create, FeaturedWork)
    end
  end
end
