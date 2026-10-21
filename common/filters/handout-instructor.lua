-- Instructor handout: everything the student handout has, plus the .instructor
-- material set off visually so it is obvious at a glance what not to project.
--
--   .instructor -> kept, rendered as a block quote led by a bold label
--   .handout    -> unwrapped
--   .slides     -> dropped

local function has_class(el, name)
  for _, c in ipairs(el.classes) do
    if c == name then return true end
  end
  return false
end

local LABEL = "Instructor note"

function Div(el)
  if has_class(el, "instructor") then
    local content = el.content:clone()
    -- Lead with a bold label. Attaching it to the first paragraph (rather than
    -- adding one) keeps the block tight in both PDF and docx output.
    local first = content[1]
    if first and first.t == "Para" then
      table.insert(first.content, 1, pandoc.Space())
      table.insert(first.content, 1, pandoc.Strong(LABEL .. " —"))
    else
      table.insert(content, 1, pandoc.Para{pandoc.Strong(LABEL)})
    end
    -- The Div only gives the HTML handout a class to style; LaTeX and docx
    -- render it transparently.
    return pandoc.Div({pandoc.BlockQuote(content)},
                      pandoc.Attr("", {"teaching-note"}, {}))
  end
  if has_class(el, "slides") then return {} end
  if has_class(el, "handout") then return el.content end
end

function Span(el)
  if has_class(el, "instructor") then
    return {pandoc.Strong(el.content)}
  end
  if has_class(el, "slides") then return {} end
  if has_class(el, "handout") then return el.content end
end
