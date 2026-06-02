-- slidebox.lua — render slideboxes as styled boxes in PDF/LaTeX only.
-- Self-contained: also injects the required LaTeX definitions into the
-- preamble, so no header file or YAML wiring is needed.
-- HTML output is left completely untouched.

if not FORMAT:match('latex') then
  return {}
end

local PREAMBLE = [[
\usepackage{tcolorbox}
\tcbuselibrary{skins,breakable}
\definecolor{embernavy}{HTML}{0D1B2A}
\definecolor{emberamber}{HTML}{C8762A}
\definecolor{emberrule}{HTML}{E0D8CC}
\definecolor{emberborder}{HTML}{D8CEBC}
\newtcolorbox{slidebox}{%
  enhanced, breakable, colback=white, colframe=emberborder,
  boxrule=0.4pt, arc=1.5pt,
  left=10pt, right=10pt, top=9pt, bottom=9pt,
  borderline north={2.5pt}{0pt}{emberamber},
}
\newcommand{\slidelabel}[1]{{\color{embernavy}\bfseries\large #1\par\vspace{5pt}}}
\newenvironment{slidefooter}{%
  \par\vspace{7pt}{\color{emberrule}\rule{\linewidth}{0.4pt}}\par\vspace{4pt}%
  \color{emberamber}\itshape\small}{\par}
]]

function Meta(meta)
  local inc = meta['header-includes']
  local block = pandoc.MetaBlocks({ pandoc.RawBlock('latex', PREAMBLE) })
  if inc == nil then
    meta['header-includes'] = pandoc.MetaList({ block })
  elseif inc.t == 'MetaList' then
    inc[#inc + 1] = block
    meta['header-includes'] = inc
  else
    meta['header-includes'] = pandoc.MetaList({ inc, block })
  end
  return meta
end

function Span(el)
  if el.classes:includes('slide-label') then
    local out = { pandoc.RawInline('latex', '\\slidelabel{') }
    for _, i in ipairs(el.content) do out[#out + 1] = i end
    out[#out + 1] = pandoc.RawInline('latex', '}')
    return out
  end
end

function Div(el)
  if el.classes:includes('audio') then
    return {}
  end
  if el.classes:includes('slidebox') then
    local out = { pandoc.RawBlock('latex', '\\begin{slidebox}') }
    for _, b in ipairs(el.content) do out[#out + 1] = b end
    out[#out + 1] = pandoc.RawBlock('latex', '\\end{slidebox}')
    return out
  end
  if el.classes:includes('slide-body') then
    return el.content
  end
  if el.classes:includes('slide-footer') then
    local out = { pandoc.RawBlock('latex', '\\begin{slidefooter}') }
    for _, b in ipairs(el.content) do out[#out + 1] = b end
    out[#out + 1] = pandoc.RawBlock('latex', '\\end{slidefooter}')
    return out
  end
end
