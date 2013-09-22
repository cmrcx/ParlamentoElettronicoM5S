local members_selector = param.get("members_selector", "table")
members_selector:add_where("member.activated NOTNULL")

local initiative = param.get("initiative", "table")
local issue = param.get("issue", "table")
local initiator = param.get("initiator", "table")
local for_votes = param.get("for_votes", atom.boolean)

local paginator_name = param.get("paginator_name")

-- use the population snapshot instead of the interest or voter snapshots
local population = param.get("population", atom.boolean)

local filter = { name = "order_" .. (paginator_name or "members") }

filter[#filter+1] = {
  name = "newest",
  label = _"Newest",
  selector_modifier = function(selector) selector:add_order_by("activated DESC, id DESC") end
}
filter[#filter+1] = {
  name = "oldest",
  label = _"Oldest",
  selector_modifier = function(selector) selector:add_order_by("activated, id") end
}

filter[#filter+1] = {
  name = "name",
  label = _"A-Z",
  selector_modifier = function(selector) selector:add_order_by("name") end
}
filter[#filter+1] = {
  name = "name_desc",
  label = _"Z-A",
  selector_modifier = function(selector) selector:add_order_by("name DESC") end
}

local ui_filters = ui.filters
local filter_enabled = true
if (issue or initiative) then
  -- disable filter
  ui_filters = function(args) args.content() end
  filter_enabled = false
elseif param.get("no_filter", atom.boolean) then
  ui_filters = function(args) args.content() end
  filter_enabled = false
end

ui_filters{
  label = _"Change order",
  selector = members_selector,
  filter,
  content = function()

    -- space between filter and content
    if filter_enabled then
      slot.put("<br />")
    end

    ui.paginate{
      name = paginator_name,
      anchor = paginator_name,
      selector = members_selector,
      per_page = 50,
      content = function()
        ui.container{
          attr = { class = "member_list" },
          content = function()

            local members = members_selector:exec()

            for i, member in ipairs(members) do
              execute.view{
                module = "member",
                view = "_show_thumb",
                params = {
                  member = member,
                  initiative = initiative,
                  issue = issue,
                  initiator = initiator,
                  population = population
                }
              }
            end

          end
        }
        slot.put('<br style="clear: left;" />')
      end
    }
  end
}
