class PoliciesController < ApplicationController
  def new
    @form = PolicyForm.new(application_group_id: params[:application_group_id], household_id: params[:household_id])
  end

  def show
    @policy = Policy.find(params[:id])
    respond_to do |format|
      format.xml
    end
  end

  def create
    request = CreatePolicyRequestFactory.from_form(params[:policy_form])
    raise request.inspect

    CreatePolicy.new.execute(request)
    redirect_to application_groups_path
  end

  def edit
    @policy = Policy.find(params[:id])

    @policy.enrollees.each { |e| e.include_checked = true }

    people_not_on_plan = @policy.household.people.reject { |p| p.policies.include?(@policy)}
    people_not_on_plan.each do |person|
      @policy.enrollees << Enrollee.new(m_id: person.authority_member_id)
    end
  end

  def update
    raise params.inspect
  end

  def cancelterminate
    @cancel_terminate = CancelTerminate.new(params)
  end

  def transmit
    @cancel_terminate = CancelTerminate.new(params)

    if @cancel_terminate.valid?
      request = EndCoverageRequest.from_form(params, current_user.email)
      EndCoverage.new(self, EndCoverageAction).execute(request)
      redirect_to person_path(Policy.find(params[:id]).subscriber.person)
    else
      @cancel_terminate.errors.full_messages.each do |msg|
        flash_message(:error, msg) 
      end
      render action: 'cancelterminate'
    end

  end

end
