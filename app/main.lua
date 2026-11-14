-- Kim Jong Nope: the "Kim Jong Un is a Wanker" pin badge, drawn on Solana OS,
-- with "STAKE WITH VALIGATOR" and the Valigator logo around the bottom.
-- Pure drawing: no permissions needed. CANCEL exits.

local W, H = ui.W, ui.H          -- 320 x 218
local CX, CY = W // 2, H // 2    -- centre of the app area: 160, 109

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
local F = D - 6                  -- face: 212 px, radius 106
ui.rect(CX - F // 2, CY - F // 2, F, F, {color = WHITE, radius = F})

-- The rim text and logo, curved along the bottom of the face. The badge
-- can't rotate text, so tools/make_rim.py bakes it into art/rim.png
-- (212 x 95, placed at 54, 120). Solana OS before 0.5.9 can't show
-- images: there it's a straight line of text instead.
if ui.image then
  ui.image(CX - F // 2, 120, "art/rim.png")
else
  ui.label(CX - F // 2, 186, "STAKE WITH VALIGATOR", {size = 14, color = BLACK, w = F, align = "center"})
end

-- The words. Size 32 is the badge's bold font. Fixed black so the
-- Dark theme doesn't turn the text white on a white button.
local function line(y, text)
  ui.label(CX - F // 2, y, text, {size = 32, color = BLACK, w = F, align = "center"})
end
line(58,  "Kim Jong Un")
line(86,  "is a")
line(114, "Wanker")

-- The Union Jack, 67 x 33 px (about 1:2 like the real flag).
local FW, FH = 67, 33
local FX, FY = CX - FW // 2, 145

local function flag_on_canvas()
  local c = ui.canvas(FX, FY, FW, FH, {scale = 1, color = UJ_BLUE})
  local mx, my = FW // 2, FH // 2          -- 33, 16
  local R, B = FW - 1, FH - 1              -- right and bottom pixel

  c:rect(0, 0, FW, FH, UJ_BLUE)

  -- White saltire: both diagonals, 7 px tall bands.
  for k = -3, 3 do
    c:line(0, k, R, B + k, WHITE)
    c:line(0, B + k, R, k, WHITE)
  end

  -- Red saltire, counterchanged: on the hoist (left) half the red sits
  -- below each diagonal, on the fly (right) half above it.
  for k = 0, 2 do
    c:line(0, k, mx, my + k, UJ_RED)       -- top-left arm
    c:line(0, B + k, mx, my + k, UJ_RED)   -- bottom-left arm
  end
  for k = -2, 0 do
    c:line(mx, my + k, R, B + k, UJ_RED)   -- bottom-right arm
    c:line(mx, my + k, R, k, UJ_RED)       -- top-right arm
  end

  -- St George's cross: white border, red centre.
  c:rect(mx - 5, 0, 11, FH, WHITE)
  c:rect(0, my - 5, FW, 11, WHITE)
  c:rect(mx - 3, 0, 7, FH, UJ_RED)
  c:rect(0, my - 3, FW, 7, UJ_RED)
end

local function flag_with_rects()
  -- Solana OS before 0.5.9 has no canvas: no diagonals, just the crosses.
  local mx, my = FX + FW // 2, FY + FH // 2
  ui.rect(FX, FY, FW, FH, {color = UJ_BLUE})
  ui.rect(mx - 5, FY, 11, FH, {color = WHITE})
  ui.rect(FX, my - 5, FW, 11, {color = WHITE})
  ui.rect(mx - 3, FY, 7, FH, {color = UJ_RED})
  ui.rect(FX, my - 3, FW, 7, {color = UJ_RED})
end

if ui.canvas then flag_on_canvas() else flag_with_rects() end

function on_key(key, rep)
  return false                   -- CANCEL ("back") exits, nothing else to do
end
