-- Student handout.
--
--   .instructor -> dropped (Div and Span alike -- nothing leaks)
--   .handout    -> unwrapped
--   .slides     -> dropped

local function has_class(el, name)
  for _, c in ipairs(el.classes) do
    if c == name then return true end
  end
  return false
end

function Div(el)
  if has_class(el, "instructor") then return {} end
  if has_class(el, "slides") then return {} end
  if has_class(el, "handout") then return el.content end
end

function Span(el)
  if has_class(el, "instructor") then return {} end
  if has_class(el, "slides") then return {} end
  if has_class(el, "handout") then return el.content end
end
