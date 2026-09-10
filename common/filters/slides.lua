-- Slide build (reveal.js / beamer).
--
--   .instructor -> becomes reveal.js speaker notes (press "s" in the deck).
--                  Beamer has no notes pane, so there it is dropped instead;
--                  set -M drop_notes=true for that.
--   .handout    -> dropped (the expanded prose belongs in the handouts)
--   .slides     -> unwrapped
--
-- Spans with .instructor are dropped outright: an inline answer cannot be
-- turned into a speaker note.

local drop_notes = false

function Meta(m)
  if m.drop_notes then drop_notes = true end
end

local function has_class(el, name)
  for _, c in ipairs(el.classes) do
    if c == name then return true end
  end
  return false
end

function Div(el)
  if has_class(el, "instructor") then
    if drop_notes then return {} end
    -- pandoc's revealjs writer renders a Div with class "notes" into the
    -- speaker-notes pane rather than onto the slide itself.
    return pandoc.Div(el.content, pandoc.Attr("", {"notes"}, {}))
  end
  if has_class(el, "handout") then return {} end
  if has_class(el, "slides") then return el.content end
end

function Span(el)
  if has_class(el, "instructor") then return {} end
  if has_class(el, "handout") then return {} end
  if has_class(el, "slides") then return el.content end
end

return {{Meta = Meta}, {Div = Div, Span = Span}}
