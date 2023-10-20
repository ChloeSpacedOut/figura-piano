

# Figura Piano
A working piano that's a Figura player head!

## How to Use
You can spawn it in the world with this command. Simply copy and paste it and run it in game:

`/give @p minecraft:player_head{SkullOwner:{Id:[I;-1808656131,1539063829,-1082155612,-209998759]}}`

This avatar must be trusted for it to work. To do so, go to Figura > Permissions, click 'show disconnected avatars', and change 'Piano' to Max.
Once in the world, simply punch the notes, or right-click them with a shield to play!
Additionally, if you place a gold block 2 blocks under the piano, it will swap to a different texture ^^

## Piano Library
Instead of punching notes manually, you can manually trigger note plays though your script. If you ping this, everyone will be able to hear your note play. This can be used to automate playing songs, or use custom inputs like with your keyboard (or a midi keyboard??). You'll need to script this yourself though. To access the piano library, first create a variable based on the avatar variable.
```lua
piano_lib  =  world.avatarVars()["943218fd-5bbc-4015-bf7f-9da4f37bac59"]
```
(note, if you're using a 'ChloeSpacedIn' piano, instead use the UUID `b0e11a12-eada-4f28-bb70-eb8903219fe5`)
Once this is created, you'll be able to access the following functions:
### playNote()
```lua
piano_lib.playNote(pianoID, keyID, doesPlaySound, notePos)
```
The `playNote()` function just plays a note on the piano when run. It contains the following:
- `pianoID` is a string containing the ID of the selected piano. E.g. `"{1, 65, -102}"`. The ID is determined by the player head coordinates. To easily grab the ID, run `tostring(pos)` where `pos` is a vec3 of the selected piano head position.
- `keyID` is a string containing the ID of the note that should play. E.g. `"C2"`,`"F#3"`,`"A0"` This is just standard notation formatting of note as a letter, followed by octave as a number.
- `doesPlaySound` is a boolean which determines if a sound will play when the note is pressed. This exists to make the implementation for holding notes simple. Just keep this as `true`.
- `notePos` is a vec3 containing the world coordinates the note should play at. If left empty, it will just play at. You can simply ignore this and it will play at the player head coordinates. This is rarely useful, but if you want you can use the piano as a piano sample library (assuming you have it loaded), and play piano sounds anywhere in the world.

## Planned Features
Remind me to make these things please >w>
- Height customisation using a `setHeight()` function
- Muting pianos (locally only) by closing the lid (or with `mutePiano()`)
- Avatar addon which will prevent accidentally breaking blocks when swinging with first
- Avatar addon which does note press calculations internally and pings to prevent desync issues

## Credits
- Model by TechnoCatza
- Default texture by PierraNova
- Fancy texture by Toast
