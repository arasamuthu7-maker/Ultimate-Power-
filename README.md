# Ultimate Power Simulator

A 3D simulator game project built with Godot 4, with mobile controls, NPC dialogue, powers, enemies, and a boss prototype.

## Import into Godot on Android

1. Download this repository as a ZIP using GitHub's **Code → Download ZIP**.
2. Extract it with your Android file manager.
3. In Godot, import/open the extracted folder containing `project.godot`.
4. Run the project.

## Multiplayer milestone 1: friends co-op exploration

An early direct-ENet multiplayer prototype has been added:
- **HOST GAME** creates a session on UDP port **24560**.
- **JOIN FRIEND** connects using the host's public IP address or hostname.
- Remote players appear as hero avatars and their positions are sent over the network.
- Solo play, mobile joystick/action buttons, and NPC dialogue remain in the project.

### Important online setup

This is **not a hosted matchmaking service**. For friends on different networks to connect, the host needs a reachable public IP/hostname and UDP port **24560** forwarded to the host device, with firewall rules allowing it. Some mobile carriers and home ISPs use CGNAT or block incoming connections; direct hosting may then fail without a publicly reachable VPS/relay or a networking service. Do not share a private home IP publicly.

### Current limitations / test status

- **Not yet tested in the Godot runtime with two devices.** Treat this as a prototype until both devices connect and movement is verified.
- This milestone syncs remote player visuals/positions only. Combat, health, quests, coins, NPC actions, and boss state are not authoritative or synchronized.
- **Boss raids are planned for the next milestone**, after basic two-player connection and movement are tested.
- No account system, matchmaking, invite code, or anti-cheat is included yet.

## Main files

- `Player.gd` — player movement.
- `MobileControls.tscn`, `MobileJoystick.gd`, `MobileActionButtons.gd` — Android touch controls.
- `NPC.gd` — NPC interaction and dialogue.
- `MultiplayerManager.gd` — ENet session and remote-avatar prototype.
