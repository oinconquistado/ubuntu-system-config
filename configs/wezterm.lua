-- ~/.wezterm.lua

local wezterm = require 'wezterm'

local config = {}

config.colors = {
    background = '#313131',
    foreground = '#f5f5f5',
    tab_bar = {
        background = '#313131',
        active_tab = {
            bg_color = '#494949',
            fg_color = '#f5f5f5',
            intensity = 'Normal',
            underline = 'None',
            italic = false,
            strikethrough = false,
        },
        inactive_tab = {
            bg_color = '#313131',
            fg_color = '#808080',
            intensity = 'Normal',
            underline = 'None',
            italic = false,
            strikethrough = false,
        },
        inactive_tab_hover = {
            bg_color = '#404040',
            fg_color = '#909090',
            italic = true,
        },
        new_tab = {
            bg_color = '#313131',
            fg_color = '#808080',
        },
        new_tab_hover = {
            bg_color = '#404040',
            fg_color = '#909090',
            italic = true,
        },
    },
}

config.tab_bar_at_bottom = false
config.tab_max_width = 15

config.window_padding = {
    left = 20,
    right = 20,
    top = 15,
    bottom = 15,
}

config.window_decorations = "INTEGRATED_BUTTONS"

-- Custom keybindings
config.keys = {
  {key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}},
}

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.command_in_raw_mode or tab.active_pane.title
  if title == nil or title == '' then
    title = tab.active_pane.current_working_dir
    if title then
        title = title:match(".*/(.*)") or title
    else
        title = "WezTerm"
    end
  end

  -- Limita o título a 15 caracteres
  if #title > 15 then
    title = title:sub(1, 15)
  end

  local formatted_title = wezterm.format {
    { Text = title },
  }

  return {
    active_titlebar_bg = '#494949',
    inactive_titlebar_bg = '#313131',
    title = formatted_title,
  }
end)

return config
