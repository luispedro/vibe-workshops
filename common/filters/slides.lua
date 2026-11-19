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
--
-- Slide kinds. Every slide with content is tagged on its heading as either
--
--   .handson  -- it has something to type (a ```bash, ```claude, ... block
--                that cues.lua will box), or
--   .lecture  -- it does not,
--
-- and the deck draws the two differently (common/style/slides.css). The guess
-- is overridden by tagging the heading by hand, `## Title {.lecture}` or
-- `{.handson}`, and switched off with `{.no-tag}`. A section heading with
-- no content of its own (a part divider) is left untagged. Only what reaches
-- the slide counts: commands inside ::: handout or ::: instructor do not.

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

-- The code blocks that cues.lua turns into a "type this" box.
local TYPED_LANGS = {bash = true, sh = true, shell = true, console = true,
                     zsh = true, powershell = true, claude = true}

local SLIDE_LEVEL = 2   -- matches --slide-level in common/workshop.mk

local function is_typed(cb)
  if has_class(cb, "no-cue") then return false end
  for _, c in ipairs(cb.classes) do
    if TYPED_LANGS[c] then return true end
  end
  return false
end

-- Does this slide body have a command to type? Speaker notes do not count.
local function has_typed(blocks)
  local found = false
  local function scan(bs)
    for _, b in ipairs(bs) do
      if found then return end
      if b.t == "CodeBlock" then
        if is_typed(b) then found = true end
      elseif b.t == "Div" then
        if not has_class(b, "notes") then scan(b.content) end
      elseif b.content and b.t ~= "Header" and b.t ~= "Para" and b.t ~= "Plain" then
        -- BlockQuote, lists (lists hold a list of block lists), etc.
        pandoc.walk_block(b, {CodeBlock = function(cb)
          if is_typed(cb) then found = true end
        end})
      end
    end
  end
  scan(blocks)
  return found
end

-- Tag the heading `header` given the blocks of its slide.
local function tag(header, body)
  local cls = header.classes
  if has_class(header, "no-tag") or has_class(header, "lecture")
      or has_class(header, "handson") then
    -- set by hand
  elseif #body == 0 then
    return    -- a part divider
  elseif has_typed(body) then
    cls:insert("handson")
  else
    cls:insert("lecture")
  end
  -- reveal.js draws slide backgrounds on a layer of their own, which CSS on
  -- the <section> cannot reach: the tint has to be a data attribute.
  if FORMAT:match("revealjs") and has_class(header, "lecture")
      and not header.attributes["data-background-color"] then
    header.attributes["data-background-color"] = "#f4f7fb"
  end
end

function Pandoc(doc)
  local blocks = doc.blocks
  local current, body = nil, {}
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level <= SLIDE_LEVEL then
      if current then tag(current, body) end
      current, body = b, {}
    elseif current then
      body[#body + 1] = b
    end
  end
  if current then tag(current, body) end
  return doc
end

-- The kinds are decided last, once ::: handout is gone and ::: instructor has
-- become speaker notes.
return {{Meta = Meta}, {Div = Div, Span = Span}, {Pandoc = Pandoc}}
