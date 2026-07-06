pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- hourglass.p8
-- phase 1: static iso hourglass, hardcoded fill
-- (phase 2 sand physics / phase 3 rotation: not implemented yet)

-- ===============================
-- constants & state
-- ===============================

grid_w = 10
grid_h = 10

rim_r = 18
neck_r = 3
top_rim_y = 26
top_neck_y = 4
bot_neck_y = -4
bot_rim_y = -26

heights_top = {}
heights_bottom = {}

function _init()
 for x=1,grid_w do
  heights_top[x] = {}
  heights_bottom[x] = {}
  for y=1,grid_h do
   heights_top[x][y] = 5
   heights_bottom[x][y] = 9
  end
 end
end

-- ===============================
-- iso projection & geometry
-- ===============================

function iso_project(x,y,z)
 -- x,y,z in local 3d space, returns screen sx,sy
 local sx = 64 + (x-z)*0.87  -- 64 = screen center x
 local sy = 64 + (x+z)*0.5 - y  -- 64 = screen center y; y is vertical
 return sx,sy
end

-- builds an 8-point ring of radius r at vertical height y
function ring(r,y)
 local pts = {}
 for i=0,7 do
  local a = i/8
  add(pts,{cos(a)*r,y,sin(a)*r})
 end
 return pts
end

top_rim = ring(rim_r,top_rim_y)
top_neck = ring(neck_r,top_neck_y)
bot_neck = ring(neck_r,bot_neck_y)
bot_rim = ring(rim_r,bot_rim_y)

function draw_ring(pts,col)
 for i=1,#pts do
  local a = pts[i]
  local b = pts[i%#pts+1]
  local ax,ay = iso_project(a[1],a[2],a[3])
  local bx,by = iso_project(b[1],b[2],b[3])
  line(ax,ay,bx,by,col)
 end
end

function draw_struts(pts_a,pts_b,col)
 for i=1,#pts_a do
  local a = pts_a[i]
  local b = pts_b[i]
  local ax,ay = iso_project(a[1],a[2],a[3])
  local bx,by = iso_project(b[1],b[2],b[3])
  line(ax,ay,bx,by,col)
 end
end

function draw_hourglass()
 draw_ring(top_rim,7)
 draw_struts(top_rim,top_neck,7)
 draw_ring(top_neck,7)
 draw_ring(bot_neck,7)
 draw_struts(bot_neck,bot_rim,7)
 draw_ring(bot_rim,7)
end

-- maps a heightmap grid cell to local x,z footprint coords,
-- centered and scaled to sit inside the bulb rim
function grid_to_local(gx,gy,footprint_r)
 local cx = (grid_w+1)/2
 local cy = (grid_h+1)/2
 local scale = footprint_r/(grid_w/2)
 return (gx-cx)*scale,(gy-cy)*scale
end

-- draws one column of sand as a vertical pixel stack,
-- base_y is the local-y floor the column rests on
function draw_iso_column(lx,lz,base_y,height,col)
 if height<=0 then return end
 local sx,sy_top = iso_project(lx,base_y+height,lz)
 local _,sy_bot = iso_project(lx,base_y,lz)
 line(sx,sy_top,sx,sy_bot,col)
end

-- draws every column of a heightmap back-to-front (far first, near last)
-- so nearer/taller columns correctly occlude those behind
function draw_heightmap(heights,base_y,col)
 local footprint_r = rim_r*0.6
 for s=0,grid_w+grid_h-2 do
  for gx=1,grid_w do
   local gy = s-gx+2
   if gy>=1 and gy<=grid_h then
    local h = heights[gx][gy]
    if h>0 then
     local lx,lz = grid_to_local(gx,gy,footprint_r)
     draw_iso_column(lx,lz,base_y,h,col)
    end
   end
  end
 end
end

-- ===============================
-- update / draw
-- ===============================

function _update()
end

function _draw()
 cls(0)
 draw_heightmap(heights_bottom,bot_rim_y,9)
 draw_heightmap(heights_top,top_neck_y,9)
 draw_hourglass()
end


