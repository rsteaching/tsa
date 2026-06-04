--[[
  slidebox.lua

  PDF/LaTeX rendering for the article-style fenced divs used in the
  topic pages. The HTML look is supplied by ember.scss; LaTeX never
  sees that CSS, so this filter rebuilds the boxes as tcolorboxes
  (matching the original slide-pack tcolorboxes) for PDF output.

  No-op for non-LaTeX formats (HTML keeps using ember.scss).

  Handles:
    ::::: slidebox
    [Title]{.slide-label}
    ::: slide-body  ... :::
    ::: slide-footer ... :::
    :::::
  ->  \begin{slidebox}{Title} <body> \tcblower <footer> \end{slidebox}

  and  [Goals]{.kicker}  ->  \kicker{Goals}

  Both \slidebox (env) and \kicker (cmd) are defined in slidebox.tex.
]]

if not FORMAT:match("latex") then
  return {}
end

-- render a list of inlines to a LaTeX string (for the box title)
local function inlines_to_latex(inls)
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inls) }), "latex")
  return (s:gsub("%s+$", ""))
end

-- if a block is the label paragraph, return its inline content
local function label_inlines(blk)
  if blk.t ~= "Para" and blk.t ~= "Plain" then return nil end
  for _, inl in ipairs(blk.content) do
    if inl.t == "Span" and inl.classes:includes("slide-label") then
      return inl.content
    end
  end
  return nil
end

function Div(el)
  if not el.classes:includes("slidebox") then
    return nil  -- leave slide-body / slide-footer / others untouched
  end

  local title  = ""
  local body   = {}
  local footer = nil

  for _, blk in ipairs(el.content) do
    if blk.t == "Div" and blk.classes:includes("slide-body") then
      for _, b in ipairs(blk.content) do table.insert(body, b) end
    elseif blk.t == "Div" and blk.classes:includes("slide-footer") then
      footer = blk.content
    else
      local lab = label_inlines(blk)
      if lab ~= nil then
        title = inlines_to_latex(lab)
      else
        table.insert(body, blk)  -- preserve anything unexpected
      end
    end
  end

  local out = pandoc.List({})
  out:insert(pandoc.RawBlock("latex", "\\begin{slidebox}{" .. title .. "}"))
  for _, b in ipairs(body) do out:insert(b) end
  if footer ~= nil then
    out:insert(pandoc.RawBlock("latex", "\\tcblower"))
    for _, b in ipairs(footer) do out:insert(b) end
  end
  out:insert(pandoc.RawBlock("latex", "\\end{slidebox}"))
  return out
end

-- kicker labels (Goals / Key Equation / Key Concept ...)
function Span(el)
  if el.classes:includes("kicker") then
    return pandoc.RawInline("latex", "\\kicker{" .. inlines_to_latex(el.content) .. "}")
  end
  return nil  -- importantly, leave .slide-label spans intact for Div above
end
