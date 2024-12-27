-- plugin to parse markdown files
local M = {}

local function create_floating_window(config)
  -- create a buffer
  local buf = vim.api.nvim_create_buf(false, true) -- no file, scratch buffer

  -- create the floating window
  local win = vim.api.nvim_open_win(buf, true, config)

  return { buf = buf, win = win }
end


---@class tjpresent.Slides
---@fields slides tjpresent.Slide[]: The slides of the file

---@class tjpresent.Slide
---@field title string: The title of the slide
---@field body string[]: The body of the slide

--- Takes some lines and parses them
---@param lines string[]: The lines in the buffer
---@return tjpresent.Slides
local parse_slides = function(lines)
  local slides = { slides = {} }
  local current_slide = {
    title = "",
    body = {}
  }
  local separator = "^# "

  for _, line in ipairs(lines) do
    if line:find(separator) then
      if #current_slide.title > 0 then
        table.insert(slides.slides, current_slide)
      end
      current_slide = {
        title = line,
        body = {}
      }
    else
      table.insert(current_slide.body, line)
    end
    table.insert(current_slide, line)
  end
  table.insert(slides.slides, current_slide)

  return slides
end

M.setup = function()
  -- nothing
end

M.start_presentation = function(opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
  local parsed = parse_slides(lines)
  local width = vim.o.columns
  local height = vim.o.lines

  -- local win_config = {
  --   relative = "editor",
  --   width = width,
  --   height = height,
  --   col = col,
  --   row = row,
  --   style = "minimal", -- no borders or extra UI elements
  --   border = "rounded",
  -- }
  ---@type vim.api.keyset.win_config
  local windows = {
    background = {
      relative = "editor",
      width = width,
      height = height,
      style = "minimal",
      col = 0,
      row = 0,
      zindex = 1
    },
    header = {
      relative = "editor",
      width = width,
      height = 1,
      col = 0,
      row = 0,
      style = "minimal",
      -- border = { " ", " ", " ", " ", " ", " ", " ", " ", }
      border = "rounded",
      zindex = 2
    },
    body = {
      relative = "editor",
      width = width - 8,
      height = height - 3,
      col = 8,
      row = 4,
      style = "minimal",
      -- border = { " ", " ", " ", " ", " ", " ", " ", " ", }
    },
    -- footer = {}
  }

  local background_float = create_floating_window(windows.background)
  local header_float = create_floating_window(windows.header)
  local body_float = create_floating_window(windows.body)

  vim.bo[header_float.buf].filetype = "markdown"
  vim.bo[body_float.buf].filetype = "markdown"

  local current_slide_idx = 1

  local set_slide_content = function(idx)
    local slide = parsed.slides[idx]
    local padding = string.rep(" ", (width - #slide.title) / 2)
    local title = padding .. slide.title
    vim.api.nvim_buf_set_lines(header_float.buf, 0, -1, false, { title })
    vim.api.nvim_buf_set_lines(body_float.buf, 0, -1, false, slide.body)
  end

  -- Keymaps
  -- Go to next slide
  vim.keymap.set("n", "n", function()
    current_slide_idx = math.min(current_slide_idx + 1, #parsed.slides)
    set_slide_content(current_slide_idx)
  end, {
    buffer = body_float.buf
  })
  -- Go to previous slide
  vim.keymap.set("n", "p", function()
    current_slide_idx = math.max(current_slide_idx - 1, 1)
    set_slide_content(current_slide_idx)
  end, {
    buffer = body_float.buf
  })
  -- Quit slides
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(body_float.win, true)
  end, {
    buffer = body_float.buf
  })

  -- Restore options
  local restore = {
    cmdheight = {
      original = vim.o.cmdheight,
      on_present = 0,
    }
  }

  -- Set the options we want during presentation
  for option, config in pairs(restore) do
    vim.opt[option] = config.on_present
  end

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = body_float.buf,
    callback = function()
      -- Restore the original values when we exit the presentation
      for option, config in pairs(restore) do
        vim.opt[option] = config.original
      end

      pcall(vim.api.nvim_win_close, header_float.win, true)
      pcall(vim.api.nvim_win_close, background_float.win, true)
    end,
  })

  set_slide_content(current_slide_idx)
end

-- M.start_presentation({ bufnr = 14 })

-- vim.print(parse_slides({
--     "# Hello",
--     "this is something else",
--     "# World",
--     "this is another thing",
-- }))

return M
