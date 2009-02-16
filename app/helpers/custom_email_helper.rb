module CustomEmailHelper

  def deliverable_subject(deliverable, html=true)
    return '' unless Object.const_defined?("Deliverable") && @issue.deliverable
      
    if html
      return "<li>#{ l(:field_deliverable_subject) }: #{ @issue.deliverable.subject }</li>"
    else
      return "#{ l(:field_deliverable_subject) }: #{ @issue.deliverable.subject }"
    end
  end


end
