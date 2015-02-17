 module PdfTemplates
  class TaxHousehold
    include Virtus.model

    attribute :tax_household_coverages, Array[PdfTemplates::TaxHouseholdCoverage]

    def policy_ids
      tax_household_coverages.inject([]) {|pols, coverage| pols += coverage.policies }.flatten.uniq
    end
  end
end