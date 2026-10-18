![title](https://cdn.discordapp.com/attachments/1027004645912088686/1300263126243217438/adminmenu.jpg?ex=6720dca7&is=671f8b27&hm=6c218887153c78c50bfa0bd636c6b2b13686a2ea443a36645b81dbd7e8f37984&)

# qbx_adminmenu

Commands and a permission-aware dashboard to provide tools to admins

## Features

- Player reports
- See player names & blips
- Change players model
- Take ownership of a vehicle or spawn a new vehicle to be an owner of
- See the character names in a specific radio channel
- Open the clothing menu
- modify a player's ACE permissions
- modify a character's data such as their radio channel, job, name, thirst level, etc.
- Give a player all the weapons
- Change a player's routing bucket
- See information about a player, including various identifiers
- kill/revive/freeze/kick/ban/teleport/noclip
- Tailwind control dashboard with online player balances, dirty-money item counts, admin duty status, and role-locked tools
- Developer entity view mode with model, network, health, and heading information
- Full player lookup with cash, bank, configured black-money items, license, identifiers, owned cars, and Qbox properties
- Dashboard player actions for bring, freeze/unfreeze, kill, and set on fire, protected by the `playerActions` ability role
- Classic player actions also include set on fire alongside the existing bring, freeze, and kill tools

## Installation

Dependencies: `qbx_core`, `ox_lib`, `oxmysql`, and `ox_inventory`. Ensure this resource after those dependencies:

```cfg
ensure qbx_core
ensure ox_lib
ensure oxmysql
ensure ox_inventory
ensure qbx_adminmenu
```

The dashboard uses ACE permissions. Configure the role names, ability locks, and dirty-money item names in `config/server.lua`; the defaults are `mod`, `admin`, `god`, and `black_money`. The `abilityPerms` table controls the dashboard, player lookup, player actions, entity view, noclip, names, blips, and other local tools independently. The classic player action menu uses the same `playerActions` lock as the dashboard.

Player details read owned vehicles from Qbox's standard `player_vehicles` table and housing from the Qbox Properties `properties` table using the character's citizen ID. Missing optional tables fail safely and show an empty list; ensure the matching garage/properties resource and schema are installed for those sections to populate.

Example server permissions:

```cfg
add_ace group.admin mod allow
add_ace group.admin admin allow
add_ace group.admin god allow
add_principal identifier.license:YOUR_LICENSE group.admin
```

Use `/optin` to go on admin duty, then `/admin` to open the dashboard. Click any online player to load the complete lookup. The player action buttons wait for server confirmation. Press Escape to close it. The Classic menu button keeps the original ox_lib menu available.

## Player Commands
- /report <message> send a message to admins

## Admin Commands
- /admin opens the admin menu
- /noclip toggles noclip
- /entityview toggles developer entity view mode
- /names toggles player names
- /blips toggles player blips
- /setmodel <model> [id] change the model of the given player
- /admincar to Spawn a vehicle and take permanent ownership of it or take permanent ownership of the vehicle the admin is already sitting in
- /vec2 /vec3 /vec4 /heading copies the value to the clipboard

