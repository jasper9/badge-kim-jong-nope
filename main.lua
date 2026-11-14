-- Kim Jong Nope: the "Kim Jong Un is a Wanker" pin badge, drawn on Solana OS.
-- Pure drawing: no permissions needed. CANCEL exits.

local W, H = ui.W, ui.H          -- 320 x 218
local CX, CY = W // 2, H // 2    -- centre of the app area

local BLACK  = 0x000000
local WHITE  = 0xFFFFFF
local RIM    = 0xB8B8B8          -- the button's curled metal edge
local BACK   = 0x202020          -- what the button sits on
local UJ_BLUE = 0x012169
local UJ_RED  = 0xC8102E

ui.bg(BACK)

-- The button: a grey rim with the white face inside it.
-- A radius bigger than half the size makes LVGL draw a circle.
local D = H                      -- 218 px, the full height
ui.rect(CX - D // 2, CY - D // 2, D, D, {color = RIM, radius = D})
local F = D - 6
ui.rect(CX - F // 2, CY - F // 2, F, F, {color = WHITE, radius = F})

-- The words. Size 32 is the badge's bold font. Fixed black so the
-- Dark theme doesn't turn the text white on a white button.
local function line(y, text)
  ui.label(CX - F // 2, y, text, {size = 32, color = BLACK, w = F, align = "center"})
end
line(48,  "Kim Jong Un")
line(79,  "is a")
line(110, "Wanker")

-- The Union Jack, 91 x 45 px (1:2 like the real flag).
local FW, FH = 91, 45
local FX, FY = CX - FW // 2, 146

local function flag_on_canvas()
  local c = ui.canvas(FX, FY, FW, FH, {scale = 1, color = UJ_BLUE})
  local mx, my = FW // 2, FH // 2          -- 45, 22
  local R, B = FW - 1, FH - 1              -- right and bottom pixel

  c:rect(0, 0, FW, FH, UJ_BLUE)

  -- White saltire: both diagonals, 11 px tall bands.
  for k = -5, 5 do
    c:line(0, k, R, B + k, WHITE)
    c:line(0, B + k, R, k, WHITE)
  end

  -- Red saltire, counterchanged: on the hoist (left) half the red sits
  -- below each diagonal, on the fly (right) half above it.
  for k = 0, 3 do
    c:line(0, k, mx, my + k, UJ_RED)       -- top-left arm
    c:line(0, B + k, mx, my + k, UJ_RED)   -- bottom-left arm
  end
  for k = -3, 0 do
    c:line(mx, my + k, R, B + k, UJ_RED)   -- bottom-right arm
    c:line(mx, my + k, R, k, UJ_RED)       -- top-right arm
  end

  -- St George's cross: white border, red centre.
  c:rect(mx - 7, 0, 15, FH, WHITE)
  c:rect(0, my - 7, FW, 15, WHITE)
  c:rect(mx - 4, 0, 9, FH, UJ_RED)
  c:rect(0, my - 4, FW, 9, UJ_RED)
end

local function flag_with_rects()
  -- Solana OS before 0.5.9 has no canvas: no diagonals, just the crosses.
  ui.rect(FX, FY, FW, FH, {color = UJ_BLUE})
  ui.rect(FX + FW // 2 - 7, FY, 15, FH, {color = WHITE})
  ui.rect(FX, FY + FH // 2 - 7, FW, 15, {color = WHITE})
  ui.rect(FX + FW // 2 - 4, FY, 9, FH, {color = UJ_RED})
  ui.rect(FX, FY + FH // 2 - 4, FW, 9, {color = UJ_RED})
end

if ui.canvas then flag_on_canvas() else flag_with_rects() end

function on_key(key, rep)
  return false                   -- CANCEL ("back") exits, nothing else to do
end
