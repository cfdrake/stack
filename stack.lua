-- ~~ stack ~~
--
-- a stack of bandpass filters
--
-- ENC1 select active filter
-- KEY2 record pattern
-- KEY3 stop recording + play pattern
-- Press KEY2 then KEY3 to stop pattern (records empty pattern)

-----------------------------
-- INCLUDES, ETC.
-----------------------------

local pattern_time = require "pattern_time"

engine.name = "Stack"

-----------------------------
-- STATE
-----------------------------

sel = 0

-----------------------------
-- INIT
-----------------------------

function init()
  sel = 0
  
  pattern = pattern_time.new()
  pattern.process = process_pattern
end

-----------------------------
-- MIDI/PATTERN HANDLING
-----------------------------

function process_pattern(ev)
  sel = ev.sel
  engine.sel(sel)
  redraw()
end

-----------------------------
-- INPUT
-----------------------------

function enc(n, d)
  if n == 1 then
    sel = util.clamp(sel + d, 0, 8)
    
    ev = {}
    ev.sel = sel
        
    pattern:watch(ev)
  end
  
  engine.sel(sel)
  redraw()
end

function key(n, z)
  if n == 2 then
    if recording then
      return
    end
    
    pattern:stop()
    pattern:clear()
    pattern:rec_start()
    recording = true
  elseif n == 3 then
    pattern:rec_stop()
    pattern:start()
    recording = false
  end
  
  redraw()
end

-----------------------------
-- DRAWING
-----------------------------

function redraw()
  screen.clear()
  screen.move(0, 45)
  screen.font_face(2)
  screen.font_size(40)
  screen.level(15)
  screen.text(sel)
  screen.move(20, 45)
  screen.font_size(20)
  screen.level(3)
  screen.text(math.floor(31.5 * math.pow(2, sel + 1)) .. "hz")
  screen.move(20, 25)
  screen.font_size(10)
  screen.level(3)
  screen.text(recording and "recording" or "")
  screen.update()
end