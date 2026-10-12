-- =============================================================================
-- WezTerm configuration
-- =============================================================================

local wezterm = require 'wezterm'
local color = wezterm.color
local config = wezterm.config_builder()

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

-- Detect light vs dark system appearance.
local function is_dark()
  if wezterm.gui then
    return wezterm.gui.get_appearance():find('Dark') ~= nil
  end
  return false -- default to light if GUI state isn't ready
end

-- Pick the scheme name for the current appearance.
local function scheme_for_appearance(dark)
  if dark then
    return 'Catppuccin Mocha'
  end
  return 'Catppuccin Latte'
end

-- Build tab_bar colors by deriving shades from the scheme's own palette,
-- using wezterm's color parser instead of hard-coded hex values.
local function make_tab_bar(scheme_name, dark)
  local scheme = wezterm.color.get_builtin_schemes()[scheme_name]
  local bg = color.parse(scheme.background)
  local fg = color.parse(scheme.foreground)

  -- In dark mode we lift shades up; in light mode we push them down.
  local function shade(base, step)
    if dark then
      return base:lighten(step)
    else
      return base:darken(step)
    end
  end

  -- Muted foreground for inactive tabs.
  local fg_muted = fg:darken(dark and 0.25 or -0.25)

  -- Layered shades, all derived from the scheme background so nothing
  -- lands on pure white/black:
  --   strip   = the tab bar band (most separated from the surface)
  --   active  = a soft surface for the selected tab (avoids white glare)
  --   hover   = between strip and active
  local strip  = shade(bg, 0.14)
  local active = shade(bg, 0.05)
  local hover  = shade(bg, 0.20)

  return {
    tab_bar = {
      background = strip,
      active_tab = {
        bg_color = active, -- soft off-surface, never raw white
        fg_color = fg,
        intensity = 'Bold',
        underline = 'None',
      },
      inactive_tab = {
        bg_color = strip,
        fg_color = fg_muted,
      },
      inactive_tab_hover = {
        bg_color = hover,
        fg_color = fg,
      },
      new_tab = {
        bg_color = strip,
        fg_color = fg_muted,
      },
      new_tab_hover = {
        bg_color = hover,
        fg_color = fg,
      },
    },
  }
end

-- -----------------------------------------------------------------------------
-- Shell
-- -----------------------------------------------------------------------------

-- Dynamic path for Git Bash installed via Scoop.
local home = os.getenv('USERPROFILE')
config.default_prog = { home .. '\\scoop\\apps\\git\\current\\bin\\bash.exe', '-i' }

-- -----------------------------------------------------------------------------
-- Font
-- -----------------------------------------------------------------------------

config.font = wezterm.font('FiraMono Nerd Font')
config.font_size = 8.0
config.line_height = 1.2
config.cell_width = 1

-- -----------------------------------------------------------------------------
-- Window
-- -----------------------------------------------------------------------------

config.window_padding = {
  -- left = 0,
  -- right = 0,
  top = 0,
  bottom = 0,
}

-- Hide the Windows title bar and window frame.
config.window_decorations = 'RESIZE'

-- Simple window transparency (Acrylic/Mica blur disabled).
-- config.win32_system_backdrop = 'Auto'
config.window_background_opacity = 0.95 -- Adjust transparency (e.g., 0.85 to 0.95)

config.initial_cols = 100
config.initial_rows = 24

-- -----------------------------------------------------------------------------
-- Tab bar
-- -----------------------------------------------------------------------------

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

-- -----------------------------------------------------------------------------
-- Cursor
-- -----------------------------------------------------------------------------

config.default_cursor_style = 'BlinkingBlock'
-- config.cursor_blink_rate = 800 -- Blinking interval in milliseconds (default: 800ms)

-- -----------------------------------------------------------------------------
-- Performance / GPU
-- -----------------------------------------------------------------------------

-- Target NVIDIA High-Performance GPU.
-- config.front_end = "OpenGL"
-- config.webgpu_power_preference = "HighPerformance"
config.max_fps = 60

-- -----------------------------------------------------------------------------
-- Key bindings
-- -----------------------------------------------------------------------------

config.keys = {
  -- Ctrl+Shift+W closes the current tab immediately, no confirmation prompt.
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentTab { confirm = false },
  },
}

-- -----------------------------------------------------------------------------
-- Appearance (color scheme + derived tab bar colors)
-- -----------------------------------------------------------------------------

local dark = is_dark()
local scheme_name = scheme_for_appearance(dark)
config.color_scheme = scheme_name
config.colors = make_tab_bar(scheme_name, dark)

-- -----------------------------------------------------------------------------
-- Event handlers
-- -----------------------------------------------------------------------------

-- Display current folder name on tabs.
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local cwd_uri = pane.current_working_dir
  local folder_name = ''

  if cwd_uri then
    local path = cwd_uri.file_path
    folder_name = path:match('([^/\\]+)[/\\]?$') or path
  end

  if folder_name == '' then
    folder_name = 'Git Bash'
  end

  return ' ' .. (tab.tab_index + 1) .. ': ' .. folder_name .. ' '
end)

return config
