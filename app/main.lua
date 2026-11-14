-- Kim Jong Nope: the "Kim Jong Un is a Wanker" pin badge, full screen on
-- Solana OS, with "STAKE WITH [Valigator logo] VALIGATOR" along the bottom.
-- Pure drawing: no permissions needed. CANCEL exits.

local W, H = ui.W, ui.H          -- 320 x 218
local CX = W // 2                -- 160

local BLACK   = 0x000000
local WHITE   = 0xFFFFFF
local UJ_BLUE = 0x012169
local UJ_RED  = 0xC8102E

ui.bg(BLACK)

-- The words. Size 32 is the badge's bold font. Fixed colours so the
-- Light theme doesn't turn the text black on the black background.
local function line(y, text, size)
  ui.label(0, y, text, {size = size, color = WHITE, w = W, align = "center"})
end
line(12, "Kim Jong Un", 32)
line(43, "is a", 32)
line(74, "Wanker", 32)

-- The Union Jack, 91 x 45 px (1:2 like the real flag).
local FW, FH = 91, 45
local FX, FY = CX - FW // 2, 110

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
  local mx, my = FX + FW // 2, FY + FH // 2
  ui.rect(FX, FY, FW, FH, {color = UJ_BLUE})
  ui.rect(mx - 7, FY, 15, FH, {color = WHITE})
  ui.rect(FX, my - 7, FW, 15, {color = WHITE})
  ui.rect(mx - 4, FY, 9, FH, {color = UJ_RED})
  ui.rect(FX, my - 4, FW, 9, {color = UJ_RED})
end

if ui.canvas then flag_on_canvas() else flag_with_rects() end

-- Bottom row: STAKE WITH [logo] VALIGATOR, the logo in the middle.
-- art/logo.png is 27 x 28, made by tools/make_logo.py.
local LW, LH, LY = 27, 28, 170
local GAP = 10
local TY = LY + LH // 2 - 6      -- size 14 text, capitals centred on the logo
if ui.image then
  ui.image(CX - LW // 2, LY, "art/logo.png")
  local left = CX - LW // 2 - GAP
  ui.label(0, TY, "STAKE WITH", {size = 14, color = WHITE, w = left, align = "right"})
  ui.label(CX + LW // 2 + 1 + GAP, TY, "VALIGATOR", {size = 14, color = WHITE})
else
  -- Solana OS before 0.5.9 can't show images: text only.
  line(TY, "STAKE WITH VALIGATOR", 14)
end

function on_key(key, rep)
  return false                   -- CANCEL ("back") exits, nothing else to do
end
