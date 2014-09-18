module Parsers::Xml::IrsReports
  class Policy
    
    attr_accessor :individuals
    
    def initialize(parser = nil)
      @root = parser
      @individuals = []
      covered_individuals
    end

    def covered_individuals
      @root.xpath("n1:enrollees/n1:subscriber").each do |individual|
        @individuals << individual
      end

      @root.xpath("n1:enrollees/n1:members/n1:member").each do |individual|
        @individuals << individual
      end
    end

    def id
      @root.at_xpath("n1:id").text
    end

    def start_date
      @individuals[0].at_xpath("n1:benefit/n1:begin_date").text
    end

    def end_date
      @individuals[0].at_xpath("n1:benefit/n1:end_date").text if @individuals[0].at_xpath("n1:benefit/n1:end_date")
    end

    def household_aptc
    end

    def total_monthly_premium
      @root.at_xpath("n1:enrollment/n1:premium_amount_total").text
    end

    def qhp_policy_num
    end

    def qhp_issuer_ein
    end

    def qhp_id
      @root.at_xpath("n1:enrollment/n1:plan/n1:qhp_id").text.gsub(/-/,"")
    end
  end
end