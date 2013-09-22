local initiator = param.get("initiator", "table")
local member = param.get("member", "table")

local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

local population = param.get("population", atom.boolean)

local highlight = param.get("highlight", atom.boolean)

local name_html
if member.name_highlighted then
  name_html = encode.highlight(member.name_highlighted)
else
  name_html = encode.html(member.name)
end

local container_class = "member_thumb"
if initiator and member.accepted ~= true then
  container_class = container_class .. " not_accepted"
end

if member.is_informed == false then
  container_class = container_class .. " not_informed"
end

if highlight or ((issue or initiative) and member.id == app.session.member_id) then
  container_class = container_class .. " in_delegation_chain"
end

ui.container{
  attr = { class = container_class },
  content = function()
    ui.container{
      attr = { class = "flags" },
      content = function()

        if not member.active then
          local text = _"inactive"
          ui.image{
            attr = { alt = text, title = text },
            static = "icons/16/cross.png"
          }
        elseif member.member_valid == false then
          ui.tag{ content = _"no voting right" }
        end

        if member.grade then
          ui.link{
            module = "vote",
            view = "list",
            params = {
              issue_id = initiative.issue.id,
              member_id = member.id,
            },
            content = function()
              if member.voter_comment then
                ui.image{
                  attr = {
                    alt   = _"Voting comment available",
                    title = _"Voting comment available"
                  },
                  static = "icons/16/comment.png"
                }
              end
              if member.grade > 0 then
                ui.image{
                  attr = {
                    alt   = _"Voted yes",
                    title = _"Voted yes"
                  },
                  static = "icons/16/thumb_up_green.png"
                }
              elseif member.grade < 0 then
                ui.image{
                  attr = {
                    alt   = _"Voted no",
                    title = _"Voted no"
                  },
                  static = "icons/16/thumb_down_red.png"
                }
              else
                ui.image{
                  attr = {
                    alt   = _"Abstention",
                    title = _"Abstention"
                  },
                  static = "icons/16/bullet_yellow.png"
                }
              end
            end
          }
        end

        if initiator and initiator.accepted then
          if member.accepted == nil then
            slot.put(_"Invited")
          elseif member.accepted == false then
            slot.put(_"Rejected")
          end
        end

        if member.is_informed == false then
          local text = _"Member has not approved latest draft."
          ui.image{
            attr = { alt = text, title = text },
            static = "icons/16/help_yellow.png"
          }
        end

        if member.admin then
          local text = _"Member is administrator."
          ui.image{
            attr = { alt = text, title = text },
            static = "icons/16/cog.png"
          }
        end

        if member.saved then
          local text = _"You have saved this member as contact."
          ui.image{
            attr = { alt = text, title = text },
            static = "icons/16/bullet_disk.png"
          }
        end

      end
    }

    ui.link{
      attr = { title = _"Show member" },
      module = "member",
      view = "show",
      id = member.id,
      content = function()
        execute.view{
          module = "member_image",
          view = "_show",
          params = {
            member = member,
            image_type = "avatar",
            show_dummy = true
          }
        }
        ui.container{
          attr = { class = "member_name" },
          content = function() slot.put(name_html) end
        }
      end
    }
  end
}
