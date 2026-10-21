-- Content-type cues: the visual vocabulary shared by all three outputs.
--
-- Two families, and the styling keeps them apart at a glance:
--
--   DO   -- something the reader types. Solid left bar, monospace body.
--            ```bash / ```sh / ```shell / ```console   -> "type in the shell"
--            ```claude                                 -> "type to Claude"
--   KNOW -- something the reader should carry away. Full box, decreasing
--            weight as the material becomes more optional:
--            ::: remember   filled   -- the point of the slide
--            ::: aside      tinted   -- advanced / tangent
--            ::: reference  dashed   -- not covered, here for later
--
-- Add {.no-cue} to a code block that is *output* or a diagram rather than
-- something to type: ```{.bash .no-cue}
--
-- Run this filter *after* the audience filter (slides.lua / handout-*.lua) so
-- that cues inside a dropped ::: handout or ::: instructor block never get
-- rendered at all.

local CUES = {
  shell     = {label = "⌨  Type this in the shell", cls = "cue-shell",     env = "cueshell"},
  claude    = {label = "✳  Type this to Claude",    cls = "cue-claude",    env = "cueclaude"},
  remember  = {label = "★  Remember",               cls = "cue-remember",  env = "cueremember"},
  aside     = {label = "⊳  Aside · advanced",       cls = "cue-aside",     env = "cueaside"},
  reference = {label = "☰  Reference · for later",  cls = "cue-reference", env = "cuereference"},
}

-- Code-block languages that mean "the reader types this at a shell prompt".
local SHELL_LANGS = {bash = true, sh = true, shell = true, console = true, zsh = true}

local is_html  = FORMAT:match("html") or FORMAT:match("revealjs")
local is_latex = FORMAT:match("latex") or FORMAT:match("beamer")

local function has_class(el, name)
  for _, c in ipairs(el.classes) do
    if c == name then return true end
  end
  return false
end

-- Wrap already-rendered blocks in the box for `kind`.
local function box(kind, blocks)
  local cue = CUES[kind]
  if is_html then
    local label = pandoc.Div({pandoc.Plain{pandoc.Str(cue.label)}},
                             pandoc.Attr("", {"cue-label"}, {}))
    local content = {label}
    for _, b in ipairs(blocks) do content[#content + 1] = b end
    return pandoc.Div(content, pandoc.Attr("", {"cue", cue.cls}, {}))
  end
  if is_latex then
    local content = {pandoc.RawBlock("latex", "\\begin{" .. cue.env .. "}")}
    for _, b in ipairs(blocks) do content[#content + 1] = b end
    content[#content + 1] = pandoc.RawBlock("latex", "\\end{" .. cue.env .. "}")
    return content
  end
  -- docx and anything else: a labelled block quote is the most portable
  -- rendering that still separates the two families visually.
  local content = {pandoc.Para{pandoc.Strong(cue.label)}}
  for _, b in ipairs(blocks) do content[#content + 1] = b end
  return pandoc.BlockQuote(content)
end

function CodeBlock(el)
  if has_class(el, "no-cue") then return nil end
  local kind
  if has_class(el, "claude") then
    kind = "claude"
    -- "claude" is not a language pandoc can highlight; drop it so the block
    -- renders as plain verbatim rather than as an unknown-language warning.
    el.classes = {}
  else
    for _, c in ipairs(el.classes) do
      if SHELL_LANGS[c] then kind = "shell" break end
    end
  end
  if not kind then return nil end
  return box(kind, {el})
end

-- The KNOW family, most to least prominent. Checked in this order so that a
-- Div carrying two of them resolves predictably.
local DIV_CUES = {"remember", "aside", "reference"}

function Div(el)
  for _, kind in ipairs(DIV_CUES) do
    if has_class(el, kind) then return box(kind, el.content) end
  end
end

-- [`bio` `informatics`]{.tokens}: each code span is one token. The deck draws
-- them as chips in slides.css; here the PDFs get the same chips from cues.tex,
-- and docx, which has no inline boxes, gets brackets so the boundaries inside
-- a word stay visible.
function Span(el)
  if not has_class(el, "tokens") or is_html then return nil end
  return el:walk {
    Code = function(c)
      if is_latex then
        return {pandoc.RawInline("latex", "\\tokchip{"), c, pandoc.RawInline("latex", "}")}
      end
      return {pandoc.Str("["), c, pandoc.Str("]")}
    end
  }
end

return {{CodeBlock = CodeBlock, Div = Div, Span = Span}}
