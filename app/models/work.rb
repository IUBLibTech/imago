# Generated via
#  `rails generate curation_concerns:work GenericWork`
class Work < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior
  self.human_readable_type = 'Work'

  property :collection_code, predicate: ::RDF::Vocab::DWC.collectionCode do |index|
    index.as :stored_searchable, :facetable
  end
  property :catalog_number, predicate: ::RDF::Vocab::DWC.catalogNumber do |index|
    index.as :stored_searchable, :facetable
  end
  property :other_catalog_numbers, predicate: ::RDF::Vocab::DWC.otherCatalogNumbers do |index|
    index.as :stored_searchable, :facetable
  end
  property :continent, predicate: ::RDF::Vocab::DWC.continent do |index|
    index.as :stored_searchable, :facetable
  end
  property :country, predicate: ::RDF::Vocab::DWC.country do |index|
    index.as :stored_searchable, :facetable
  end
  property :state_province, predicate: ::RDF::Vocab::DWC.stateProvince do |index|
    index.as :stored_searchable, :facetable
  end
  property :county, predicate: ::RDF::Vocab::DWC.county do |index|
    index.as :stored_searchable, :facetable
  end
  property :higher_geography, predicate: ::RDF::Vocab::DWC.higherGeography do |index|
    index.as :stored_searchable, :facetable
  end
  property :locality, predicate: ::RDF::Vocab::DWC.locality do |index|
    index.as :stored_searchable, :facetable
  end
  property :decimal_latitude, predicate: ::RDF::Vocab::DWC.decimalLatitude do |index|
    index.as :stored_searchable, :facetable
  end
  property :decimal_longitude, predicate: ::RDF::Vocab::DWC.decimalLongitude do |index|
    index.as :stored_searchable, :facetable
  end
  property :scientific_name, predicate: ::RDF::Vocab::DWC.scientificName do |index|
    index.as :stored_searchable, :facetable
  end
  property :scientific_name_authorship, predicate: ::RDF::Vocab::DWC.scientificNameAuthorship do |index|
    index.as :stored_searchable, :facetable
  end
  property :kingdom, predicate: ::RDF::Vocab::DWC.kingdom do |index|
    index.as :stored_searchable, :facetable
  end
  property :phylum, predicate: ::RDF::Vocab::DWC.phylum do |index|
    index.as :stored_searchable, :facetable
  end
  property :dwcclass, predicate: ::RDF::Vocab::DWC.class do |index|
    index.as :stored_searchable, :facetable
  end
  property :order, predicate: ::RDF::Vocab::DWC.order do |index|
    index.as :stored_searchable, :facetable
  end
  property :family, predicate: ::RDF::Vocab::DWC.family do |index|
    index.as :stored_searchable, :facetable
  end
  property :genus, predicate: ::RDF::Vocab::DWC.genus do |index|
    index.as :stored_searchable, :facetable
  end
  property :specific_epithet, predicate: ::RDF::Vocab::DWC.specificEpithet do |index|
    index.as :stored_searchable, :facetable
  end
  property :infraspecific_epithet, predicate: ::RDF::Vocab::DWC.infraspecificEpithet do |index|
    index.as :stored_searchable, :facetable
  end
  property :type_status, predicate: ::RDF::Vocab::DWC.typeStatus do |index|
    index.as :stored_searchable, :facetable
  end
  property :basis_of_record, predicate: ::RDF::Vocab::DWC.basisOfRecord do |index|
    index.as :stored_searchable, :facetable
  end

  #new for paleo
  property :bed, predicate: ::RDF::Vocab::DWC.bed do |index|
    index.as :stored_searchable, :facetable
  end
  property :dwcmember, predicate: ::RDF::Vocab::DWC.member do |index|
    index.as :stored_searchable, :facetable
  end
  property :formation, predicate: ::RDF::Vocab::DWC.formation do |index|
    index.as :stored_searchable, :facetable
  end
  property :group, predicate: ::RDF::Vocab::DWC.group do |index|
    index.as :stored_searchable, :facetable
  end
  property :latest_age_or_highest_stage, predicate: ::RDF::Vocab::DWC.latestAgeOrHighestStage do |index|
    index.as :stored_searchable, :facetable
  end
  property :earliest_age_or_lowest_stage, predicate: ::RDF::Vocab::DWC.earliestAgeOrLowestStage do |index|
    index.as :stored_searchable, :facetable
  end
  property :latest_period_or_highest_system, predicate: ::RDF::Vocab::DWC.latestPeriodOrHighestSystem do |index|
    index.as :stored_searchable, :facetable
  end
  property :earliest_period_or_lowest_system, predicate: ::RDF::Vocab::DWC.earliestPeriodOrLowestSystem do |index|
    index.as :stored_searchable, :facetable
  end

  #new for self deposit
  property :institution_code, predicate: ::RDF::Vocab::DWC.institutionCode do |index|
    index.as :stored_searchable, :facetable
  end
  property :occurrence_id, predicate: ::RDF::Vocab::DWC.occurrenceID do |index|
    index.as :stored_searchable, :facetable
  end
  property :country_code, predicate: ::RDF::Vocab::DWC.countryCode do |index|
    index.as :stored_searchable, :facetable
  end
  property :taxon_rank, predicate: ::RDF::Vocab::DWC.taxonRank do |index|
    index.as :stored_searchable, :facetable
  end
  property :water_body, predicate: ::RDF::Vocab::DWC.waterBody do |index|
    index.as :stored_searchable, :facetable
  end
  property :location_remarks, predicate: ::RDF::Vocab::DWC.locationRemarks do |index|
    index.as :stored_searchable, :facetable
  end
  property :geodetic_datum, predicate: ::RDF::Vocab::DWC.geodeticDatum do |index|
    index.as :stored_searchable, :facetable
  end

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
end
