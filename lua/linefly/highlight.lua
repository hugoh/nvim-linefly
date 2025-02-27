local is_empty = require("linefly.utils").is_empty
local is_present = require("linefly.utils").is_present
local options = require("linefly.options").list
local g = vim.g
local highlight = vim.api.nvim_set_hl
local hlexists = vim.fn.hlexists
local hlID = vim.fn.hlID
local synIDtrans = vim.fn.synIDtrans
local synIDattr = vim.fn.synIDattr

-- Cache current statusline background for performance reasons; that being to
-- avoid needless highlight extraction and generation.
local statusline_bg

local highlight_empty = function(group)
  return hlexists(group) ~= 1 or is_empty(synIDattr(synIDtrans(hlID(group)), "bg"))
end

local synthesize_highlight = function(target, source, reverse)
  local source_fg

  if reverse then
    source_fg = synIDattr(synIDtrans(hlID(source)), "bg", "gui")
  else
    source_fg = synIDattr(synIDtrans(hlID(source)), "fg", "gui")
  end

  if is_present(statusline_bg) and is_present(source_fg) then
    highlight(0, target, { bg = statusline_bg, fg = source_fg })
  else
    -- Fallback to statusline highlighting.
    highlight(0, target, { link = "StatusLine" })
  end
end

local synthesize_mode_highlight = function(target, background, foreground)
  local mode_bg = synIDattr(synIDtrans(hlID(background)), "fg", "gui")
  local mode_fg = synIDattr(synIDtrans(hlID(foreground)), "fg", "gui")

  if is_present(mode_bg) and is_present(mode_fg) then
    highlight(0, target, { bg = mode_bg, fg = mode_fg })
  else
    -- Fallback to statusline highlighting.
    highlight(0, target, { link = "StatusLine" })
  end
end

local colorscheme_diagnostic_highlights = function()
  if hlexists("DiagnosticError") == 1 then
    synthesize_highlight("LineflyDiagnosticError", "DiagnosticError", false)
  else
    highlight(0, "LineflyDiagnosticError", { link = "StatusLine" })
  end
  if hlexists("DiagnosticWarn") == 1 then
    synthesize_highlight("LineflyDiagnosticWarning", "DiagnosticWarn", false)
  else
    highlight(0, "LineflyDiagnosticWarning", { link = "StatusLine" })
  end
  if hlexists("DiagnosticInfo") == 1 then
    synthesize_highlight("LineflyDiagnosticInformation", "DiagnosticInfo", false)
  else
    highlight(0, "LineflyDiagnosticInformation", { link = "StatusLine" })
  end
end

local colorscheme_git_highlights = function()
  if hlexists("GitSignsAdd") == 1 then
    synthesize_highlight("LineflyGitAdd", "GitSignsAdd", false)
    synthesize_highlight("LineflyGitChange", "GitSignsChange", false)
    synthesize_highlight("LineflyGitDelete", "GitSignsDelete", false)
  elseif hlexists("diffAdded") == 1 then
    synthesize_highlight("LineflyGitAdd", "diffAdded", false)
    synthesize_highlight("LineflyGitChange", "diffChanged", false)
    synthesize_highlight("LineflyGitDelete", "diffRemoved", false)
  else
    highlight(0, "LineflyGitAdd", { link = "StatusLine" })
    highlight(0, "LineflyGitChange", { link = "StatusLine" })
    highlight(0, "LineflyGitDelete", { link = "StatusLine" })
  end
end

local colorscheme_mode_highlights = function()
  if g.colors_name == "moonfly" or g.colors_name == "nightfly" then
    -- Do nothing since both colorschemes already set linefly mode colors.
    return
  elseif g.colors_name == "catppuccin" then
    synthesize_mode_highlight("LineflyNormal", "Title", "VertSplit")
    synthesize_mode_highlight("LineflyInsert", "String", "VertSplit")
    synthesize_mode_highlight("LineflyVisual", "Statement", "VertSplit")
    synthesize_mode_highlight("LineflyCommand", "Constant", "VertSplit")
    synthesize_mode_highlight("LineflyReplace", "Conditional", "VertSplit")
  elseif g.colors_name == "edge" or g.colors_name == "everforest"
    or g.colors_name == "gruvbox-material" or g.colors_name == "sonokai"
    or g.colors_name == "tokyonight" then
    highlight(0, "LineflyNormal", { link = "MiniStatuslineModeNormal" })
    highlight(0, "LineflyInsert", { link = "MiniStatuslineModeInsert" })
    highlight(0, "LineflyVisual", { link = "MiniStatuslineModeVisual" })
    highlight(0, "LineflyCommand", { link = "MiniStatuslineModeCommand" })
    highlight(0, "LineflyReplace", { link = "MiniStatuslineModeReplace" })
  elseif g.colors_name == "kanagawa" then
    synthesize_mode_highlight("LineflyNormal", "Directory", "VertSplit")
    synthesize_mode_highlight("LineflyInsert", "GitSignsAdd", "VertSplit")
    synthesize_mode_highlight("LineflyVisual", "Conditional", "VertSplit")
    synthesize_mode_highlight("LineflyCommand", "Operator", "VertSplit")
    synthesize_mode_highlight("LineflyReplace", "GitSignsDelete", "VertSplit")
  elseif g.colors_name == "dracula" then
    highlight(0, "LineflyNormal", { link = "WildMenu" })
    highlight(0, "LineflyInsert", { link = "Search" })
    synthesize_mode_highlight("LineflyVisual", "String", "WildMenu")
    highlight(0, "LineflyCommand", { link = "WildMenu" })
    highlight(0, "LineflyReplace", { link = "IncSearch" })
  elseif g.colors_name == "gruvbox" then
    synthesize_mode_highlight("LineflyNormal", "GruvboxFg4", "GruvboxBg0")
    synthesize_mode_highlight("LineflyInsert", "GruvboxBlue", "GruvboxBg0")
    synthesize_mode_highlight("LineflyVisual", "GruvboxOrange", "GruvboxBg0")
    synthesize_mode_highlight("LineflyCommand", "GruvboxGreen", "GruvboxBg0")
    synthesize_mode_highlight("LineflyReplace", "GruvboxRed", "GruvboxBg0")
  elseif g.colors_name == "carbonfox" or g.colors_name == "nightfox"
    or g.colors_name == "nordfox" or g.colors_name == "terafox" then
    highlight(0, "LineflyNormal", { link = "Todo" })
    highlight(0, "LineflyInsert", { link = "MiniStatuslineModeInsert" })
    highlight(0, "LineflyVisual", { link = "MiniStatuslineModeVisual" })
    highlight(0, "LineflyCommand", { link = "MiniStatuslineModeCommand" })
    highlight(0, "LineflyReplace", { link = "MiniStatuslineModeReplace" })
  else
    -- Fallback for all other colorschemes.
    if highlight_empty("LineflyNormal") then
      synthesize_mode_highlight("LineflyNormal", "Directory", "VertSplit")
    end
    if highlight_empty("LineflyInsert") then
      synthesize_mode_highlight("LIneflyInsert", "String", "VertSplit")
    end
    if highlight_empty("LineflyVisual") then
      synthesize_mode_highlight("LineflyVisual", "Statement", "VertSplit")
    end
    if highlight_empty("LineflyCommand") then
      synthesize_mode_highlight("LineflyCommand", "WarningMsg", "VertSplit")
    end
    if highlight_empty("LineflyReplace") then
      synthesize_mode_highlight("LineflyReplace", "Error", "VertSplit")
    end
  end
end

local M = {}

M.generate_groups = function()
  if g.colors_name == nil then
    return
  end

  -- Extract current StatusLine background color, we will likely need it.
  if synIDattr(synIDtrans(hlID("StatusLine")), "reverse", "gui") == "1" then
    -- Need to handle reversed highlights, such as Gruvbox StatusLine.
    statusline_bg = synIDattr(synIDtrans(hlID("StatusLine")), "fg", "gui")
  else
    -- Most colorschemes fall through to here.
    statusline_bg = synIDattr(synIDtrans(hlID("StatusLine")), "bg", "gui")
  end

  -- Mode highlights.
  colorscheme_mode_highlights()

  -- Synthesize emphasis colors from the existing mode colors.
  synthesize_highlight("LineflyNormalEmphasis", "LineflyNormal", true)
  synthesize_highlight("LineflyInsertEmphasis", "LineflyInsert", true)
  synthesize_highlight("LineflyVisualEmphasis", "LineflyVisual", true)
  synthesize_highlight("LineflyCommandEmphasis", "LineflyCommand", true)
  synthesize_highlight("LineflyReplaceEmphasis", "LineflyReplace", true)

  -- Synthesize plugin colors from relevant existing highlight groups.
  colorscheme_git_highlights()
  colorscheme_diagnostic_highlights()
  highlight(0, "LineflySession", { link = "LineflyGitAdd" })

  if options().tabline and highlight_empty("TablineSelSymbol") then
    highlight(0, "TablineSelSymbol", { link = "TablineSel" })
  end
end

return M
