-- Lua filter: convert Unicode box-drawing tables into native pandoc tables.
-- Handles multi-line cells (text split across rows between dividers).

local PIPE = "\226\148\130"  -- │ U+2502

local function stringify_inlines(inlines)
  local buf = {}
  for _, el in ipairs(inlines) do
    if el.t == "Str" then
      buf[#buf + 1] = el.text
    elseif el.t == "Space" then
      buf[#buf + 1] = " "
    elseif el.t == "SoftBreak" or el.t == "LineBreak" then
      buf[#buf + 1] = "\n"
    end
  end
  return table.concat(buf)
end

local function is_box_table(text)
  return text:find("\226\148\140")   -- ┌
      and text:find(PIPE)            -- │
      and text:find("\226\148\152")  -- └
end

local function split_lines(text)
  local lines = {}
  for line in text:gmatch("([^\n]*)\n?") do
    lines[#lines + 1] = line
  end
  while #lines > 0 and lines[#lines] == "" do
    lines[#lines] = nil
  end
  return lines
end

local function is_divider(line)
  -- A divider line contains only box-drawing horizontals/corners and spaces
  -- Check for ─ (U+2500 = \226\148\128) presence and no │ (U+2502)
  if not line:find("\226\148\128") then return false end
  if line:find(PIPE) then return false end
  return true
end

local function split_cells(line)
  -- Split a data row by │ (exact 3-byte sequence)
  -- First check that the line contains │
  if not line:find(PIPE) then return nil end

  local cells = {}
  local pos = 1
  local len = #line
  local segments = {}

  -- Find all positions of │
  while pos <= len do
    local s, e = line:find(PIPE, pos, true)
    if not s then
      segments[#segments + 1] = line:sub(pos)
      break
    end
    segments[#segments + 1] = line:sub(pos, s - 1)
    pos = e + 1
  end
  -- If we ended exactly on a │, add empty trailing segment
  if line:sub(len - 2, len) == PIPE then
    segments[#segments + 1] = ""
  end

  -- segments[1] is before the first │ (should be empty/whitespace)
  -- segments[2..n-1] are the cell contents
  -- segments[n] is after the last │ (should be empty/whitespace)
  if #segments < 3 then return nil end

  for i = 2, #segments - 1 do
    local trimmed = segments[i]:match("^%s*(.-)%s*$") or ""
    cells[#cells + 1] = trimmed
  end

  return cells
end

local function merge_cell_lines(a, b)
  local merged = {}
  local n = math.max(#a, #b)
  for i = 1, n do
    local av = (a[i] or ""):match("^%s*(.-)%s*$") or ""
    local bv = (b[i] or ""):match("^%s*(.-)%s*$") or ""
    if av ~= "" and bv ~= "" then
      merged[i] = av .. " " .. bv
    else
      merged[i] = av .. bv
    end
  end
  return merged
end

function Para(el)
  local text = stringify_inlines(el.content)
  if not is_box_table(text) then return nil end

  local lines = split_lines(text)

  -- Group lines between dividers into logical rows
  local groups = {}
  local current = {}
  for _, line in ipairs(lines) do
    if is_divider(line) then
      if #current > 0 then
        groups[#groups + 1] = current
        current = {}
      end
    else
      current[#current + 1] = line
    end
  end
  if #current > 0 then
    groups[#groups + 1] = current
  end

  if #groups < 2 then return nil end

  -- Parse each group into merged cell values
  local parsed_rows = {}
  for _, group in ipairs(groups) do
    local merged = nil
    for _, line in ipairs(group) do
      local cells = split_cells(line)
      if cells then
        if merged == nil then
          merged = cells
        else
          merged = merge_cell_lines(merged, cells)
        end
      end
    end
    if merged then
      parsed_rows[#parsed_rows + 1] = merged
    end
  end

  if #parsed_rows < 2 then return nil end

  local header_cells = parsed_rows[1]
  local ncols = #header_cells

  local header_row = {}
  for _, celltext in ipairs(header_cells) do
    header_row[#header_row + 1] = {pandoc.Plain(pandoc.Inlines(celltext))}
  end

  local body_rows = {}
  for i = 2, #parsed_rows do
    local row = {}
    for j = 1, ncols do
      local celltext = parsed_rows[i][j] or ""
      row[#row + 1] = {pandoc.Plain(pandoc.Inlines(celltext))}
    end
    body_rows[#body_rows + 1] = row
  end

  local aligns = {}
  local widths = {}
  for i = 1, ncols do
    aligns[i] = pandoc.AlignDefault
    widths[i] = 0
  end

  return pandoc.utils.from_simple_table(
    pandoc.SimpleTable("", aligns, widths, header_row, body_rows)
  )
end
