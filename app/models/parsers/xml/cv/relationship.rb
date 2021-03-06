module Parsers::Xml::Cv
  class Relationship
    include NodeUtils

    RELATIONSHIP_MAP = {
      "is the aunt of" => "aunt_or_uncle",
      "is the child of" => "child",
      "is the cousin of" => "cousin",
      "is the domestic partner of" => "life_partner",
      "is the grandchild of" => "grandchild",
      "is the grandparent of" => "grandparent",
      "is the great grandparent of" => "great_grandparent",
      "is the guardian of" => "guardian",
      "is the nephew of" => "nephew_or_niece",
      "is the niece of" => "nephew_or_niece",
      "is the parent of" => "parent",
      "is the person cared for by" => "", #TODO
      "is the sibling of" => "sibling",
      "is the spouse of" => "spouse",
      "is the step child of" => "stepchild",
      "is the step parent of" => "stepparent",
      "is the step sibling of" => "sibling",
      "is the uncle of" => "aunt_or_uncle",
      "is unrelated to" => "unrelated"
    }

    def initialize(parser)
      @parser = parser
    end

    def subject
      data = first_text('./ns1:subject_individual')
      return nil if data.blank?
      return nil if data.split("#").last.blank?
      data
    end

    def relationship
      data = first_text('./ns1:relationship_uri')
      data.blank? ? nil : RELATIONSHIP_MAP[data.downcase.strip]
    end

    def object
      data = first_text('./ns1:object_individual')
      return nil if data.blank?
      return nil if data.split("#").length < 2
      data
    end

    def empty?
      (([subject, relationship, object].any?(&:blank?)) || (subject == object))
    end

    def to_request
      {
        :subject_person => subject,
        :object_person => object,
        :relationship_kind => relationship
      }
    end
  end
end
