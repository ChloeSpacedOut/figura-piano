require('utils')
require('tables')
pianos = {}
debug = false
playerRaycastRange = 3



function events.skull_render(delta,block,item,entity,mode)
  -- scans through every key and resets the position
  for k,pianoID in pairs(pianos) do
    for keyID,timecode in pairs(pianoID.playingKeys) do
      models.Piano.SKULL.Piano.Keys['C'..string.sub(keyID,-1,-1)][keyID]:setRot(0,0,0)
    end
  end

  -- sets the scale of piano items to be small, and blocks to be large
  if mode == "BLOCK" then
    models.Piano.SKULL.Piano:setScale(1,1,1)
  else
    models.Piano.SKULL.Piano:setScale(0.3,0.3,0.3)
    models:setPrimaryTexture("CUSTOM",textures['PierraNovaPiano'])
    return
  end

  -- creates piano table element when a piano is first placed down
  local pos = block:getPos()
  local pianoID = tostring(pos)

  -- changes the piano texture if there's a gold 2 blocks under the player head
  if world.getBlockState(pos.x,pos.y-2,pos.z):getID() == "minecraft:gold_block" then
    models:setPrimaryTexture("CUSTOM",textures['ToastPiano'])
  else
    models:setPrimaryTexture("CUSTOM",textures['PierraNovaPiano'])
  end

  -- creats new piano entry if head was just placed
  if pianos[pianoID] == nil then
    pianos[pianoID] = {pos = pos, playingKeys = {}}
  end

  -- checks table for checked keys, and presses the key if the key press was less than 3 ticks ago
  for keyID,keyPresstime in pairs(pianos[pianoID].playingKeys) do
    if world.getTime() < keyPresstime + 3 then
      models.Piano.SKULL.Piano.Keys['C'..string.sub(keyID,-1,-1)][keyID]:setRot(-4,0,0)
    else
      -- clears the keypress data for keys that were pressed more than 3 ticks ago
      pianos[pianoID].playingKeys[keyID] = nil
    end
  end
end

-- function used to check for the missing black notes. (they're annoying)
function checkForEmptyKeys(keyXPos)
  local returnVal = false
  for i,v in pairs(emptyKeys) do
    if keyXPos == v then
      returnVal = true
    end
  end
  return returnVal
end

-- plays note ^^
function playNote(pianoID, keyID, doesPlaySound, notePos, noteVolume)
  if pianos[pianoID].playingKeys[keyID] == nil then
    pianos[pianoID].playingKeys[keyID] = {}
  end
  if not noteVolume then
    noteVolume = 2
  end
  pianos[pianoID].playingKeys[keyID] = world.getTime()
  if not doesPlaySound then return end
  if notePos then
    sounds:playSound(keyPitches[keyID][2],notePos,noteVolume,keyPitches[keyID][1])
  else
    sounds:playSound(keyPitches[keyID][2],pianos[pianoID].pos,noteVolume,keyPitches[keyID][1])
  end
  
end

function playSound(keyID,notePos,noteVolume)
  sounds:playSound(keyPitches[keyID][2],notePos,noteVolume,keyPitches[keyID][1])
end

-- stores important functions so that other avatars can access them through avatarVars() in the world API
avatar:store("playNote",playNote)
avatar:store("playSound",playSound)
avatar:store("validPos", function(pianoID) return pianos[pianoID] ~= nil end)
avatar:store("getPlayingKeys", function(pianoID) return pianos[pianoID] ~= nil and pianos[pianoID].playingKeys or nil end)

-- the tick function >~>
function events.world_tick()
  for i,v in pairs(pianos) do
    if world.getBlockState(v.pos).id ~= "minecraft:player_head" then
      pianos[i] = nil
    end
  end

  -- runs this code for every player
  for k,player in pairs(world.getPlayers()) do repeat
    if not (player:isUsingItem() or player:getSwingTime() == 1 or debug) then break end
    local pos = player:getPos()
    local avatarVars = world:avatarVars()[player:getUUID()]
    local eyeOffset
    if avatarVars then 
      eyeOffset = avatarVars.eyePos
    end
    if not eyeOffset then eyeOffset = 0 end

    -- run this code for every piano
    for pianoID,pianoData in pairs(pianos) do repeat
      local pianoPos = pianoData.pos

      -- escapes if the piano has been placed on a wall
      if world.getBlockState(pianoPos).properties == nil then break end
      
      ------ calculates raycast abd returns intersection with main bounding boxes for black and white notes ------ 
      local pianoRot = vec(0,-world.getBlockState(pianoPos).properties.rotation*22.5+180,0)
      local pivot = vec(0.5,0,0.5)
      local worldOffset = pianoPos + pivot

      local eyePos = rotateAroundPivot(-pianoRot,vec(pos.x,pos.y+player:getEyeHeight(),pos.z)-worldOffset+eyeOffset,vec(0,0,0))
      local lookDir = rotateAroundPivot(-pianoRot,player:getLookDir(),vec(0,0,0))

      local ray = {origin = eyePos, dir = lookDir}
      rayIntersections = {}

      for boxID,bounding in pairs(boundingBoxes) do
        local box = bounding
        local intersection = boxRayIntersection(box,ray)
        rayIntersections[boxID] = intersection
        ---- debug ----
        if debug then
          -- spawn box corner particles
          for cornerID,corner in pairs (computeCorners(box)) do
            particles:newParticle("minecraft:dust 0 0.7 0.7 0.1",worldOffset + rotateAroundPivot(pianoRot,corner,vec(0,0,0)))
          end
        end
        ---------------
      end
      ------------------------------------------- end of section -------------------------------------------------

      keyID = nil
      if rayIntersections.blackNotes then

        -- converts x value from raycast to numeric intersection ID for notes from 1 to 31, and skips missing notes
        intersection = rayIntersections.blackNotes
        local noteXpos = (intersection.x+44/32-0.0407)*16
        checkForEmptyKeys(math.ceil(noteXpos))
        local skippedKeys = 0
        for k,v in ipairs(emptyKeys) do
          if noteXpos > v then
            skippedKeys = skippedKeys + 1
          end
        end
        local keyIntersectID = math.floor(noteXpos)-skippedKeys+1

        -- uses intersection ID to find surrounding notes and uses box raycasting to determine what black note the player is looking at (if they're lookin at one)
        for k = 1, 3 do
          local numericID = math.clamp(keyIntersectID+(k-2)-1,0,30)
          local value = boxRayIntersection(blackKeyBoundingBoxes[numericID],ray)
          ---- debug ----
          if debug then
            for cornerID,corner in pairs (computeCorners(blackKeyBoundingBoxes[numericID])) do
              particles:newParticle("minecraft:dust 0.7 0 0.7 0.1",worldOffset + rotateAroundPivot(pianoRot,corner,vec(0,0,0)))
            end
          end
          ---------------
          if value ~= nil then
            ---- debug ----
            if debug then
              -- spawn lookat colission particles
              particles:newParticle("minecraft:dust 1 0 0 0.1",worldOffset + rotateAroundPivot(pianoRot,value,vec(0,0,0)))
            end
            ---------------
            -- converts numeric ID to string ID
            keyID = numberToBlackNote[(numericID-1) % 5+1].."#"..math.floor((numericID-1)/5+1)
          end
        end

      end
      -- only executes if the ray intesected with a white note and black note intersection didn't find anything
      if rayIntersections.whiteNotes and keyID == nil then
        intersection = rayIntersections.whiteNotes

        -- converts x value from racast to numeric ID
        local numericID = math.clamp(math.floor((intersection.x+44/32)*16),0,43)

        -- converts numeric ID to string ID
        keyID = numberToWhiteNote[(numericID-2) % 7+1]..math.floor((numericID-2)/7+1)
        ---- debug ----
        if debug then
          -- spawn lookat colission particles
          particles:newParticle("minecraft:dust 1 0 0 0.1",worldOffset + rotateAroundPivot(pianoRot,intersection,vec(0,0,0)))
        end
        ---------------
      end
      if keyID == nil then break end
      playNote(pianoID,keyID,pianos[pianoID].playingKeys[keyID] == nil)
      
    until true end
  until true end

  -- clears any piano table elements if there's not a head there anymore
  for k,v in pairs(pianos) do
    if world.getBlockState(v.pos).id ~= "minecraft:player_head" then
      pianos[k] = nil
    end
  end
end