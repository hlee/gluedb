module Listeners
  class NewEnrollmentListener

    def initialize(other_details, responder)
      @errors = {}
      @errors[:policies] = []
      @errors[:individuals] = []
      @current_person = 0
      @current_policy = 0
      @responder = responder
      @other_details = other_details
      @policy_ids = []
      @canceled_policies = []
    end

    def policy_canceled(p_id)
      @canceled_policies << p_id
    end

    def fail
      @responder.handle_failure(@other_details, @errors)
    end

    def success
      @responder.handle_success(@other_details, @policy_ids, @canceled_policies)
    end

    def policy_created(p_id)
      @policy_ids << p_id
    end

    def set_current_policy(idx)
      @current_policy = idx
    end

    def set_current_person(idx)
      @current_person = idx
    end

    # Enrollment errors
    def no_individuals
      add_error(:enrollment, "has no individuals")
    end

    def no_policies
      add_error(:enrollment, "has no policies")
    end

    def no_subscriber_for_policies
      add_error(:enrollment, "has no subscriber")
    end

    def carrier_switch_renewal(details)
      add_error(:enrollment, "requires a carrier switch: new enrollment_group_ids: #{details[:new_enrollment_group_id]}, old policy: enrollment_group_id: #{details[:old_policy][:enrollment_group_id]}, policy_id: #{details[:old_policy][:policy_id]}")
    end

    def enrollees_changed_for_renewal(details)
      add_error(:enrollment, "the number of enrollees has changed: was #{details[:old_policy]} is now #{details[:new_policy]}")
    end

    # Policy Errors
    def policy_already_exists(details)
      eg_id = details[:enrollment_group_id]
      hios_id = details[:hios_id]
      add_policy_error(:policy, "already exists with HIOS #{hios_id} and Enrollment Group ID #{eg_id}")
    end

    def broker_not_found(details)
      add_policy_error(:broker, "not found for npn #{details[:npn]}")
    end

    def plan_not_found(details)
      add_policy_error(:plan, "not found for HIOS #{details[:hios_id]} and year #{details[:plan_year]}")
    end

    def employer_not_found(details)
      add_policy_error(:employer, "not found for fein #{details[:fein]}")
    end

    def no_employer_contribution_data(details)
      add_policy_error(:employer, "has no contribution data: fein #{details[:employer_fein]}, date #{details[:coverage_start]}")
    end

    def invalid_policy(details)
      details.each_pair do |k, v|
        add_policy_error(k, v)
      end
    end

    def no_enrollees
      add_policy_error(:enrollees, "is empty")
    end

    # Premium errors
    def invalid_premium_total(details)
      add_policy_error(:premium_total, "expected: #{details[:expected]}, calculated: #{details[:calculated]}")
    end

    def invalid_employer_contribution(details)
      add_policy_error(:employer_contribution, "expected: #{details[:expected]}, calculated: #{details[:calculated]}")
    end

    def invalid_responsible_total(details)
      add_policy_error(:responsible_total, "expected: #{details[:expected]}, calculated: #{details[:calculated]}")
    end

    def invalid_member_premium(details)
      add_policy_error(:member_premium, "expected: #{details[:expected]}, calculated: #{details[:calculated]}")
    end

    def invalid_enrollee(details)
      details.each_pair do |k, v|
        add_policy_error("enrollees_#{k}", v)
      end
    end

    # Person errors
    def invalid_person(details)
      details.each_pair do |k, v|
        add_person_error(k, v)
      end
    end

    def invalid_member(details)
      details.each_pair do |k, v|
        add_person_error(k, v)
      end
    end

    def person_match_error(error_message)
      add_person_error(:person_match_failure, error_message)
    end

    protected

    def add_error(property, message)
      @errors[property] ||= []
      @errors[property] = @errors[property] + [message]
    end

    def add_person_error(property, message)
      @errors[:individuals][@current_person] ||= {}
      @errors[:individuals][@current_person][property] ||= []
      @errors[:individuals][@current_person][property] = @errors[:individuals][@current_person][property] + [message]
    end

    def add_policy_error(property, message)
      @errors[:policies][@current_policy] ||= {}
      @errors[:policies][@current_policy][property] ||= []
      @errors[:policies][@current_policy][property] = @errors[:policies][@current_policy][property] + [message]
    end
  end
end
