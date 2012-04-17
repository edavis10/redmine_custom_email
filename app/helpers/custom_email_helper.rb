module CustomEmailHelper

  def deliverable_subject(deliverable, html=true)
    return '' unless Object.const_defined?("Deliverable") && @issue.deliverable
      
    if html
      return "<li>#{ l(:field_deliverable_title) }: #{ @issue.deliverable.title }</li>"
    else
      return "#{ l(:field_deliverable_title) }: #{ @issue.deliverable.title }"
    end
  end

  def deliverable_labor_budget(user, issue, html=true)
    return '' unless Object.const_defined?("Deliverable") && issue.deliverable && user && user.allowed_to?(:manage_budget, issue.project)

    text = "#{ l(:field_labor_spent) }: " # Label
    text += "#{issue.deliverable.hours_spent_total} #{ l(:field_hours) } (#{ number_to_currency(issue.deliverable.total_spent) }) " # Used
    text += "#{issue.deliverable.estimated_hour_budget_total} #{ l(:field_hours) } (#{ number_to_currency(issue.deliverable.labor_budget_total) }) " # Total 

    if html
      return content_tag(:li, text)
    else
      return text

    end
  end

  def issue_spent_hours(user, issue, html=true)
    return '' unless user && user.allowed_to?(:view_time_entries, issue.project)

    if html
      return "<li>#{ l(:label_spent_time) }: #{ issue.spent_hours } of #{ issue.estimated_hours || 0 } #{ l(:field_hours) }</li>"
    else
      return "#{ l(:label_spent_time) }: #{ issue.spent_hours } of #{ issue.estimated_hours || 0 } #{ l(:field_hours) }"
    end
  end
end
