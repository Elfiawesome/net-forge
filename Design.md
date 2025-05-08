
- CORE: Core means any resource (gdscript, resources, textures etc) that are required and used for the basic functionality of the game to work. Like handling networking, entity system etc. CORE would mostly contain a lot of the code.
- GAME PACKS: Game Packs are where all the game textures data are stored in. A game should already have a main game pack inside the res:// folder for where all the main assets, logic are stored. You can think of it as game packs being something another player can come and create other game packs and import them into the game as modifications like texture pack or addition of new units. Game packs however must not contain code inside of it.

- any RegistrySimple objects that are used for storing objects/scenes etc are to be used only for CORE related objects
- CORE related resources are to be saved using the REGISTRY system through RegistrySimple or any extension of it. For example, PacketHandlers (for both server and client) uses the REGISTRY system to load its asset because packet handlers are core functions of the game and required for base game to work.
- Game packs are to be loaded through the global GamePackLoader (*WIP*). GamePackLoader will store all the data of the game packs accordingly. (*Still would need to decide wether the resources like textures are loaded all at once on start or during runtime*)


Structure (WIP):
- The root node of the game is the main.tscn scene. Here we can specify wether we are joining or creating a game session
- Server:
- Client: