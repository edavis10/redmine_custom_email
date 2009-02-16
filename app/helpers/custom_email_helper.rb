module CustomEmailHelper

  def deliverable_subject(deliverable, html=true)
    return '' unless Object.const_defined?("Deliverable") && @issue.deliverable
      
    if html
      return "<li>#{ l(:field_deliverable_subject) }: #{ @issue.deliverable.subject }</li>"
    else
      return "#{ l(:field_deliverable_subject) }: #{ @issue.deliverable.subject }"
    end
  end

  def deliverable_labor_budget(user, issue, html=true)
    return '' unless Object.const_defined?("Deliverable") && issue.deliverable && user && user.allowed_to?(:manage_budget, issue.project)

    if html
      return "<li>#{ l(:label_labor_budget_spent) }: #{ number_to_currency(issue.deliverable.labor_budget) }</li>"
    else
      return "#{ l(:label_labor_budget_spent) }: #{ number_to_currency(issue.deliverable.labor_budget) }"

    end
  end

  def issue_spent_hours(user, issue, html=true)
    return '' unless user && user.allowed_to?(:view_time_entries, issue.project)

    if html
      return "<li>#{ l(:label_spent_hours) }: #{ issue.spent_hours } of #{ issue.estimated_hours || 0 } #{ l(:field_hours) }</li>"
    else
      return "#{ l(:label_spent_hours) }: #{ issue.spent_hours } of #{ issue.estimated_hours || 0 } #{ l(:field_hours) }"
    end
  end
end
