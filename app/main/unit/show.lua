local unit_id = param.get_id()
local unit = Unit:by_id(unit_id)

if not unit then
  slot.put_into("error", _"The requested unit does not exist!")
  return
end

app.html_title.title = unit.name
app.html_title.subtitle = _("Unit")

slot.select("head", function()
  execute.view{ module = "unit", view = "_head", params = { unit = unit, show_content = true, member = app.session.member } }
end)

local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }
  :add_order_by("area.direct_member_count DESC")
  :add_order_by("area.name")

local open_issues_selector = Issue:new_selector()
  :join("area", nil, "area.id = issue.area_id")
  :add_where{ "area.unit_id = ?", unit.id }
  :add_where("issue.closed ISNULL")
  :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")

local closed_issues_selector = Issue:new_selector()
  :join("area", nil, "area.id = issue.area_id")
  :add_where{ "area.unit_id = ?", unit.id }
  :add_where("issue.closed NOTNULL")
  :add_order_by("issue.closed DESC")

local tabs = {
  module = "unit",
  view = "show",
  id = unit.id
}

tabs[#tabs+1] = {
  name = "areas",
  label = _"Areas",
  module = "area",
  view = "_list",
  params = {
    areas_selector = areas_selector,
    member = app.session.member
  }
}

tabs[#tabs+1] = {
  name = "open",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "open",
    issues_selector = open_issues_selector,
    for_unit = true
  }
}

tabs[#tabs+1] = {
  name = "closed",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "closed",
    issues_selector = closed_issues_selector,
    for_unit = true
  }
}

tabs[#tabs+1] = {
  name = "timeline",
  label = _"Latest events",
  module = "event",
  view = "_list",
  params = {
    for_unit = unit
  }
}

if app.session:has_access("all_pseudonymous") then

  local members_selector = Member:build_selector{
    active = true,
    voting_right_for_unit_id = unit.id
  }
    :left_join("contact", nil, { "contact.other_member_id = member.id AND contact.member_id = ?", app.session.member_id })
    :add_field("contact.member_id NOTNULL", "saved")
  tabs[#tabs+1] = {
    name = "eligible_voters",
    label = _"Eligible voters",
    module = "member",
    view = "_list",
    params = { members_selector = members_selector }
  }

end

ui.tabs(tabs)