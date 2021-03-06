# Better Storage Tanks

**Version: 0.3.6**

**Short description:**

Factorio mod that allows picking up storage tanks without dumping their contents.

**Long description:**

In vanilla, when you mine a storage tank, you just get the storage tank. Whatever liquid was inside it is lost, spilled on the ground and evaporated. Or not, who knows. This mod allows your character to pick up the storage tank and all of it's contents, and then place it somewhere else, like the allmighty strongman he is.
Now there is also a GUI button that dumps all contents of the storage tank.

**Changelog:**
 - 0.1.0 First upload, no public testing yet
 - 0.1.1 Debug flag set to false
 - 0.2.0 Rebuilt handler for Storage Tank mining, now you can't mine stuff with full inventory. Fixed a bug with "ghost item" in hand
 - 0.2.1 Added icon generator. Looks meh, but whatever. Fixed another "ghost item" in hand bug
 - 0.2.2 Added GUI that allows to dump contents of the storage tank
 - 0.2.3 Now liquid is properly removed from the entity before it is mined. No longer duplicates liquids in the system
 - 0.3.0 Rebuilt handler AGAIN. Now it's less spaghetti and more code! Removed various bugs. Construction bots finally can properly place EMPTY Storage Tanks in blueprints (they used to use crude oil tanks because alphabet and reasons). Health is properly retained through mining and placing the storage tank.
 - 0.3.1 Fixed crash on attempt to mine storage tank with filtered quickbar
 - 0.3.2 Removed some silly code. Bots can't mine non-empty tanks anymore.
 - 0.3.3 Added new data table, it should prevent issues with multiplayer (if there was any).
 - 0.3.4 Fixed an error on deconstruction "Passed index is out of range".
 - 0.3.5 Fixed an error on GUI click "Attempt to index field 'opened' (a nil value)".
 - 0.3.6 Replaced .has_filters() with .supports_filters() because Factorio devs like clarity.
