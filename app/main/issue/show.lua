local issue = Issue:by_id(param.get_id())

if not issue then
  slot.put_into("error", _"The requested issue does not exist!")
  return
end

if app.session.member_id then
  issue:load_everything_for_member_id(app.session.member_id)
end

if not app.html_title.title then
	app.html_title.title = _("Issue ##{id}", { id = issue.id })
end

slot.select("head", function()
  execute.view{ module = "area", view = "_head", params = { area = issue.area } }
end)

util.help("issue.show")

slot.select("head", function()
  execute.view{ module = "issue", view = "_show", params = { issue = issue } }
end )

if app.session:has_access("all_pseudonymous") then

  local tabs = {
    module = "issue",
    view = "_list"
  }

  -- interested members
  local interested_members_selector = issue:get_reference_selector("interested_members_snapshot")
    :join("issue", nil, "issue.id = direct_interest_snapshot.issue_id")
    :add_field("direct_interest_snapshot.weight")
    :add_where("direct_interest_snapshot.event = issue.latest_snapshot_event")
  tabs[#tabs+1] = {
    name = "members",
    label = _"Interested members" .. Member:count_string(interested_members_selector),
    module = "member",
    view = "_list",
    params = {
      issue = issue,
      members_selector = interested_members_selector
    }
  }

  -- population
  local populating_members_selector = issue:get_reference_selector("populating_members_snapshot")
    :join("issue", nil, "issue.id = direct_population_snapshot.issue_id")
    :add_field("direct_population_snapshot.weight")
    :add_where("direct_population_snapshot.event = issue.latest_snapshot_event")
  tabs[#tabs+1] = {
    name = "population",
    label = _"Population" .. Member:count_string(populating_members_selector),
    module = "member",
    view = "_list",
    params = {
      issue = issue,
      members_selector = populating_members_selector,
      population = true
    }
  }

  ui.tabs(tabs)

  -- issue details
  execute.view{
    module = "issue",
    view = "_details",
    params = { issue = issue }
  }

  slot.put('<div class="clearfix"></div>')

end

if config.absolute_base_short_url then
  ui.container{
    attr = { class = "shortlink" },
    content = function()
      slot.put(_"Short link" .. ": ")
      local link = config.absolute_base_short_url .. "t" .. issue.id
      ui.link{ external = link, text = link }
    end
  }
end
