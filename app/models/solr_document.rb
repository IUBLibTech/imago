# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds CurationConcerns behaviors to the SolrDocument.
  include CurationConcerns::SolrDocumentBehavior
  # Adds Sufia behaviors to the SolrDocument.
  include Sufia::SolrDocumentBehavior

  def collection_code
    self[Solrizer.solr_name('collection_code')]
  end
  def catalog_number
    self[Solrizer.solr_name('catalog_number')]
  end
  def other_catalog_numbers
    self[Solrizer.solr_name('other_catalog_numbers')]
  end
  def continent
    self[Solrizer.solr_name('continent')]
  end
  def country
    self[Solrizer.solr_name('country')]
  end
  def state_province
    self[Solrizer.solr_name('state_province')]
  end
  def county
    self[Solrizer.solr_name('county')]
  end
  def higher_geography
    self[Solrizer.solr_name('higher_geography')]
  end
  def locality
    self[Solrizer.solr_name('locality')]
  end
  def decimal_latitude
    self[Solrizer.solr_name('decimal_latitude')]
  end
  def decimal_longitude
    self[Solrizer.solr_name('decimal_longitude')]
  end
  def scientific_name
    self[Solrizer.solr_name('scientific_name')]
  end
  def scientific_name_authorship
    self[Solrizer.solr_name('scientific_name_authorship')]
  end
  def kingdom
    self[Solrizer.solr_name('kingdom')]
  end
  def phylum
    self[Solrizer.solr_name('phylum')]
  end
  def dwcclass
    self[Solrizer.solr_name('dwcclass')]
  end
  def order
    self[Solrizer.solr_name('order')]
  end
  def family
    self[Solrizer.solr_name('family')]
  end
  def genus
    self[Solrizer.solr_name('genus')]
  end
  def specific_epithet
    self[Solrizer.solr_name('specific_epithet')]
  end
  def infraspecific_epithet
    self[Solrizer.solr_name('infraspecific_epithet')]
  end
  def type_status
    self[Solrizer.solr_name('type_status')]
  end
  def basis_of_record
    self[Solrizer.solr_name('basis_of_record')]
  end

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )
end
