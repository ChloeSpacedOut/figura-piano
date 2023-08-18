function rotateAroundPivot(rot,pos,pivot) 
  local rotationMatrix = matrices.mat4()
  rotationMatrix:translate(pos) --pos
  rotationMatrix:rotate(rot) --rot
  return (rotationMatrix*pivot:augmented()).xyz
end


-- function to check if a ray intersects with a box
function boxRayIntersection(box, ray) -- written by Wolfy ^w^
  -- calculate the intersection times for each axis of the box
  ray.dir_inv = vec( 1/ray.dir.x, 1/ray.dir.y, 1/ray.dir.z)
  local t1x = (box.min.x - ray.origin.x) * ray.dir_inv.x
  local t2x = (box.max.x - ray.origin.x) * ray.dir_inv.x
  local t1y = (box.min.y - ray.origin.y) * ray.dir_inv.y
  local t2y = (box.max.y - ray.origin.y) * ray.dir_inv.y
  local t1z = (box.min.z - ray.origin.z) * ray.dir_inv.z
  local t2z = (box.max.z - ray.origin.z) * ray.dir_inv.z

  -- find the minimum and maximum intersection times across all axes
  local tmin = math.max(math.min(t1x, t2x), math.min(t1y, t2y), math.min(t1z, t2z))
  local tmax = math.min(math.max(t1x, t2x), math.max(t1y, t2y), math.max(t1z, t2z))

  -- check if the intersection times are valid
  if tmax > math.max(tmin, 0) then
    -- return the intersection point and the intersection time
    local intersection_point = ray.origin + tmin * ray.dir
    return intersection_point, tmin
  end

  -- return nil if the ray does not intersect with the box
  return nil
end

function computeCorners(box) -- written by AI. Not me!
  -- Initialize the list of corners
  local corners = {}

  -- Iterate over the dimensions of the box
  for x = 0, 1 do
    for y = 0, 1 do
      for z = 0, 1 do
        -- Compute the corner position using the min or max values of the box
        local xpos = x == 0 and box.min.x or box.max.x
        local ypos = y == 0 and box.min.y or box.max.y
        local zpos = z == 0 and box.min.z or box.max.z
        local corner = vec(xpos, ypos, zpos)

        -- Add the corner to the list
        table.insert(corners, corner)
      end
    end
  end

  -- Return the list of corners
  return corners
end