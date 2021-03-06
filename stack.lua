-- ~~ stack ~~
--
-- a stack of bandpass filters
--
-- ENC1 select active filter
-- KEY2 record pattern
-- KEY3 stop recording + play pattern
-- Press KEY2 then KEY3 to stop pattern (records empty pattern)

-----------------------------
-- INCLUDES
-----------------------------

local pattern_time = require "pattern_time"

-----------------------------
-- ENGINE
-----------------------------

engine.name = "Stack"

-----------------------------
-- STATE
-----------------------------

recording = false
initital_monitor_level = 0

-----------------------------
-- INIT / CLEANUP
-----------------------------

function init()
  setup_grid()
  setup_params()
  setup_pattern()
end

function cleanup()
  params:set('monitor_level', initital_monitor_level)
end

-----------------------------
-- HELPERS
-----------------------------

function set_active_filter(idx)
  engine.v1(idx == 1 and 1 or 0)
  engine.v2(idx == 2 and 1 or 0)
  engine.v3(idx == 3 and 1 or 0)
  engine.v4(idx == 4 and 1 or 0)
  engine.v5(idx == 5 and 1 or 0)
  engine.v6(idx == 6 and 1 or 0)
  engine.v7(idx == 7 and 1 or 0)
  engine.v8(idx == 8 and 1 or 0)
  engine.v9(idx == 9 and 1 or 0)
  
  if recording then
    ev = {}
    ev.idx = idx
    pattern:watch(ev)
  end
  
  redraw()
  redraw_grid()
end

function filter_hz(idx)
  return math.floor(31.5 * math.pow(2, idx))
end

function setup_params()
  initital_monitor_level = params:get('monitor_level')
  params:set('monitor_level', -math.huge)
  
  params:add_number("filter", "Selected Filter", 1, 9, 1)
  params:set_action("filter", function(idx) set_active_filter(idx) end)

  params:set("filter", 1)  
  set_active_filter(1)
end

function setup_pattern()
  pattern = pattern_time.new()
  pattern.process = process_pattern
end

function setup_grid()
  g = grid.connect()
  g.key = grid_key
end

-----------------------------
-- MIDI/PATTERN HANDLING
-----------------------------

function process_pattern(ev)
  params:set("filter", ev.idx)
end

-----------------------------
-- INPUT
-----------------------------

function enc(n, d)
  -- Select filter
  params:delta("filter", d)
end

function key(n, z)
  if n == 2 then
    -- Start recording
    if recording then
      return
    end
    
    pattern:stop()
    pattern:clear()
    pattern:rec_start()
    recording = true
  elseif n == 3 then
    -- Start playback
    pattern:rec_stop()
    pattern:start()
    recording = false
  end
  
  redraw()
  redraw_grid()
end

function grid_key(x, y, z)
  if y == 1 and z == 1 then
    params:set("filter", x)
  elseif y == 2 and x == 1 then
    key(2, z)
  elseif y == 2 and x == 2 then
    key(3, z)
  end
  
  redraw_grid()
end

-----------------------------
-- DRAWING
-----------------------------

function redraw_grid()
  g:all(0)
  g:led(params:get("filter"), 1, 15)
  g:led(1, 2, recording and 15 or 1)
  g:refresh()
end

function redraw()
  screen.clear()
  
  filter = params:get("filter")
  
  -- Filter index
  screen.move(2, 47)
  screen.font_face(2)
  screen.font_size(40)
  screen.level(1)
  screen.text(filter)
  screen.move(0, 45)
  screen.level(15)
  screen.text(filter)
  
  -- Filter hz
  screen.font_size(30)
  screen.move(28, 46)
  screen.level(1)
  screen.text(filter_hz(filter) .. "hz")
  screen.move(27, 45)
  screen.level(15)
  screen.text(filter_hz(filter) .. "hz")
  
  -- Recording indicator
  screen.font_size(10)
  screen.move(111, 11)
  screen.level(1)
  screen.text(recording and "* rec" or "")
  screen.move(110, 10)
  screen.level(15)
  screen.text(recording and "* rec" or "")
  
  screen.update()
end