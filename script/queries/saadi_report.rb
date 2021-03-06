require 'csv'

# dental_plan_ids = Plan.where({"coverage_type" => "dental"}).map(&:id).map { |tid| Moped::BSON::ObjectId.from_string(tid) }

policies = Policy.no_timeout.where(
  {"eg_id" => {"$not" => /DC0.{32}/}}
)

def bad_eg_id(eg_id)
 (eg_id =~ /\A000/) || (eg_id =~ /\+/)
end

plan_hash = Plan.all.inject({}) do |acc, p|
  acc[p.id] = p
  acc
end

carrier_hash = Carrier.all.inject({}) do |acc, c|
  acc[c.id] = c
  acc
end

CSV.open("saadi_report.csv", 'w') do |csv|
  csv << ["Enrollment Group ID", "Status", "Authority", "Policy ID", "Coverage Type", "Plan HIOS ID", "Plan Name", "Carrier Name", "HBX Id", "First", "Middle", "Last", "DOB", "SSN"]
  policies.each_slice(25) do |pols|
    used_policies = pols.reject { |pl| bad_eg_id(pl) }
    member_ids = pols.map(&:enrollees).flatten.map(&:m_id)
    people = Person.where({
      "members.hbx_member_id" => {"$in" => member_ids }
    })
    members_map = people.inject({}) do |acc, p|
      p.members.each do |m|
        acc[m.hbx_member_id] = [m, p]
      end
      acc
    end
    used_policies.each do |pol|
      plan = plan_hash[pol.plan_id]
      carrier = carrier_hash[plan.carrier_id]
      pol.enrollees.each do |en|
        member = members_map[en.m_id].first
        per = members_map[en.m_id].last
        csv << [pol.eg_id, pol.aasm_state, member.authority?, pol._id, plan.coverage_type ,plan.hios_plan_id, plan.name, carrier.name, en.m_id, per.name_first, per.name_middle, per.name_last, member.dob.strftime("%Y%m%d"), member.ssn]
      end
    end
  end
end

