# NetForge

**NetForge** is a foundational framework and starter project for Godot Engine 4, designed to facilitate the creation of online LAN multiplayer games using direct, low-level TCP networking. It deliberately bypasses Godot's high-level `MultiplayerAPI` (`MultiplayerSynchronizer`, `MultiplayerSpawner`, RPCs) to provide developers with finer control over the network layer and data transmission.

This project serves as a learning tool and a customizable base for games requiring specific network architectures or protocols.

---

## Core Goals

*   **Low-Level TCP:** Utilizes Godot's `TCPServer`, `StreamPeerTCP`, and `PacketPeerStream` for direct client-server communication over TCP sockets.
*   **Client-Server Architecture:** Clear separation between client-side logic (`client/`) and server-side logic (`server/`), with shared utilities in `common/`.
*   **Command-Pattern Packet Handling:** A flexible system for processing network messages. Incoming packets trigger specific handler scripts based on a registered packet type string.
*   **Server-Side 'Spaces':** The server manages distinct game areas or "spaces" (`ServerSpace`) using a `ServerSpaceManager`. This allows for world partitioning and ensures clients only receive data relevant to their current space.
    *   I mainly wanted to do this to have seperate maps, ongoing-battles, etc.
*   **Basic Persistence:** Includes a simple `SaveFileManager` for handling server configuration and map state using JSON files.
