function ui.wikitextarea(name, label)

  -- wiki engine selector
  ui.field.select{
    label = _"Wiki engine",
    name = "formatting_engine",
    foreign_records = {
      { id = "compat",     name = _"Traditional wiki syntax" },
      { id = "rocketwiki", name = "RocketWiki" }
    },
    attr = {
      id = "formatting_engine"
    },
    foreign_id = "id",
    foreign_name = "name",
    value = param.get("formatting_engine")
  }

  -- wiki syntax help
  ui.tag{
    tag = "div",
    content = function()
      ui.tag{
        tag = "label",
        attr = { class = "ui_field_label" },
        content = function() slot.put("&nbsp;") end,
      }
      ui.tag{
        content = function()
          ui.link{
            text = _"Syntax help",
            module = "help",
            view = "show",
            id = "wikisyntax",
            attr = {
              onClick = "this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)" }
          }
          slot.put(" (")
          ui.link{
            text = _"new window",
            module = "help",
            view = "show",
            id = "wikisyntax",
            attr = {
              onClick = "this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)",
              target = "_blank"
            }
          }
          slot.put(")")
        end
      }
    end
  }

  local height = "50ex"
  if name == "comment" then
    height = "20ex"
  end

  -- textarea
  ui.field.text{
    label = label,
    name = name,
    multiline = true,
    attr = {
      style = "height: " .. height,
      id = "content_text"
    },
    value = param.get(name)
  }

end
