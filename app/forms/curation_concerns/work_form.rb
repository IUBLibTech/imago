# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class WorkForm < Sufia::Forms::WorkForm
    self.model_class = ::Work
    self.terms += [:resource_type]

    self.terms += [:collection_code]
    self.terms += [:catalog_number]
    self.terms += [:other_catalog_numbers]
    self.terms += [:continent]
    self.terms += [:country]
    self.terms += [:state_province]
    self.terms += [:county]
    self.terms += [:higher_geography]
    self.terms += [:locality]
    self.terms += [:decimal_latitude]
    self.terms += [:decimal_longitude]
    self.terms += [:scientific_name]
    self.terms += [:scientific_name_authorship]
    self.terms += [:kingdom]
    self.terms += [:phylum]
    self.terms += [:dwcclass]
    self.terms += [:order]
    self.terms += [:family]
    self.terms += [:genus]
    self.terms += [:specific_epithet]
    self.terms += [:infraspecific_epithet]
    self.terms += [:type_status]
    self.terms += [:basis_of_record]

    #new for paleo
    self.terms += [:bed]
    self.terms += [:dwcmember]
    self.terms += [:formation]
    self.terms += [:group]
    self.terms += [:latest_age_or_highest_stage]
    self.terms += [:earliest_age_or_lowest_stage]
    self.terms += [:latest_period_or_highest_system]
    self.terms += [:earliest_period_or_lowest_system]

    #new for self-deposit
    self.terms += [:institution_code]
    self.terms += [:occurrence_id]
    self.terms += [:country_code]
    self.terms += [:taxon_rank]
    self.terms += [:water_body]
    self.terms += [:location_remarks]
    self.terms += [:geodetic_datum]

    self.required_fields = [:title, :rights]

  end
end
