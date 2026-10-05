# GogoLoot

Speedy auto loot clears sparkles without opening the loot window, auto-rolls Need, Greed, or Pass by quality, and Master Looting hands out drops for you. Clams, containers, and unlocked lockboxes open on their own. Loot faster, pull sooner.

**TL;DR**: You can't click corpses and attack new targets at the same time. This is an add-on for players who want their runs focused on speed, not wasted on loot buttons. Don't let loot slow down your zug!

## Features

⚡ **Speedy Loot** // Empties a corpse without ever flashing the loot window, and stands down while you're Master Looter so it never scoops up gear you're about to hand out.

🎲 **Smart Automated Rolls** // Need, Greed, or Pass on everything up to the quality you pick, with separate settings for parties and raids. Give individual items a roll of their own, BoP included, and set Intellect to Manual on your Warrior so those of the Owl greens wait for you while everything else rolls.

📦 **Smart Automated Opening** // Clams, sacks, crates, and unlocked lockboxes open in your bags in the background, with no clicks required. Hover a lockbox to see the Lockpicking skill it needs, and once a Rogue picks it, it opens on its own.

💰 **Automated Master Looter** // Picks who gets each quality and hands it out the moment the loot window opens, then tells the raid who got what. Become Master Looter and a pop-up sets up the run without a trip through the options.

🦺 **Safety First** // Quest items, books, recipes, mounts, pets, and legendaries are always skipped, and BoP items are never rolled on unless you say so. Containers worth more sealed, like raid gem sacks, stay shut, and nothing opens in combat, mid-cast, or when your bags are nearly full.

## Setup

1. Install the add-on, ideally using [CurseForge](https://www.curseforge.com/wow/addons/gogoloot) or [Wago](https://addons.wago.io/addons/gogoloot).
2. Enable Automated Rolls. It's off as a safety.
3. Hate clams? We all do. They're opened automatically as you loot them.
4. Raid leading? Turn on Automated Master Looting and pick who gets each quality.
5. Type `/gogo`, or Shift + Middle-Click the mini-map button, to fine-tune everything in the Options Interface.
6. _"I feel the need... the need for speedy loot!"_

## How It Works

### Mini-Map Button

Hover for each feature's On/Off state, what Automated Rolls will roll in a party and in a raid, and any lockboxes in your bags still waiting on a Rogue.

| Click | Does |
| --- | --- |
| Left-Click | Toggle Automated Rolls |
| Right-Click | Toggle Automated Opening |
| Shift + Left-Click | Toggle Announcements |
| Shift + Right-Click | Toggle Automated Master Looting |
| Shift + Middle-Click | Open the Options Interface |

### Auto Loot

* Speedy Loot and Automated Opening both need the game's own Auto Loot setting, so GogoLoot turns it on while either one is enabled and says so in chat when it does.
* Turn both off and GogoLoot leaves the setting alone.
* Want to see what's on a corpse? Hold Shift as you loot and the loot window opens as usual.
* Bags full? Speedy Loot leaves the loot window up rather than stranding the drop.

### Announcements

* **Loot** // Master Looter hand-outs go to party or raid chat, with their own quality threshold so a trash pull doesn't flood the channel.
* **Trades** // A tidy summary of every completed trade, items, enchants, and gold included, whispered to your partner, sent to group chat, or kept to yourself.
* **Rolls** // Each roll GogoLoot makes prints the item and the roll it picked, and the game's roll-by-roll chatter shrinks to one line per win: GogoLoot // Aero won [Hefty Battlehammer], Greed 95.

### Loot Toasts & Sounds

* **Loot Toasts** // A brief on-screen toast for every item and coin you pick up, plus your group's quest items and green-or-better gear. New and off by default: turn it on and tell us what you think. While it's on, your General chat tab's Item Loot and Money Loot lines step aside, and they come back when you turn the toasts off.
* **Who won, and how** // An item won on a roll says so on its toast, like Hefty Battlehammer (Aero, Need 87).
* **Loot Sounds** // A chime for corpse and chest loot at or above the quality you pick, and a bag sound when Pick Pocket actually takes something.

### Options

* **General** // Welcome message, mini-map button, and every feature's on/off switch in one place.
* **Automated Rolls** // Your roll and quality limit for parties and raids, and how rolls show up in chat.
  * **Item Overrides** // A roll of its own for any item, BoP ones included.
  * **Character Rules** // Gear with the stats you pick waits for you to roll, character by character.
* **Master Looter** // Who gets each quality, and your group's loot settings.
  * **Ignore List** // Items that skip auto-distribution and wait for you to hand them out.
* **Automated Opening** // When opening runs, and Lockbox tooltips.
  * **Openables List** // Every container GogoLoot knows, each set to Open or Ignore. Add any it's missing.
* **Loot Toasts** // Where the toasts sit, how many stack, and the font they use.
  * **Filters** // Which loot gets a toast, yours and your group's, item type by item type.
* **Loot Sounds** // The loot chime and the Pick Pocket sound.
* **Announcements** // Trade and Master Looter announcements, with an example of each.
* **Profiles** // Keep a guild raid setup and a PUG setup side by side and swap in a click.
* **Diagnostic Tools** // Reports to paste into a bug report.

## Testing & Localization Status

🔴 World of Warcraft // 12.1.0

🔴 Mists of Pandaria Classic // 5.5.4

🟢 Burning Crusade Anniversary // 2.5.6

🟢 World of Warcraft: Forever // 1.60.1

🟡 World of Warcraft: Season of Discovery // 1.15.9

🟢 World of Warcraft: Classic // 1.15.9

**Available Locales** // enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW

## Appreciation & History

🚀 **This add-on stands on the shoulders of those that came before.**

* Gogo1951's [Open Sesame](https://www.curseforge.com/wow/addons/open-sesame)
* lord\_glofuss's [Auto Open Items](https://www.curseforge.com/wow/addons/auto-open-items)
* pipsqueakcurse's [AutoClam](https://www.curseforge.com/wow/addons/autoclam)
* fr0z3nights' [kAutoOpen Dragonflight](https://www.curseforge.com/wow/addons/kautoopen-11)
* \_ForgeUser1016257's [kAutoOpen](https://www.curseforge.com/wow/addons/kautoopen)
* jejanim's [Openables (Weak Aura)](https://wago.io/gtRVJZetK)

## Get Involved

❤️ **You can help make this better!** Feedback, code contributions, testing, and localization assistance are always appreciated. If you'd like to get involved, please reach out.

* [GitHub](https://github.com/Gogo1951/GogoLoot)
* [Discord](https://discord.gg/eh8hKq992Q)

## Related Add-ons

### 🟢 Pairs With

* Arkayenro's [ArkInventory](https://www.curseforge.com/wow/addons/ark-inventory)
* plusmouse's [Baganator](https://www.curseforge.com/wow/addons/baganator)
* jaliborc's [Bagnon](https://www.curseforge.com/wow/addons/bagnon)
* Gogo1951's [Magic Eraser](https://www.curseforge.com/wow/addons/magic-eraser)

### 🟡 Overlaps

* Michigras's [Lockbox Cracker](https://www.curseforge.com/wow/addons/lockbox-cracker)

### 🔴 Alternatives

* Zhorax2730's [Gargul](https://www.curseforge.com/wow/addons/gargul)
* Yuyuli's [Speedy AutoLoot](https://www.curseforge.com/wow/addons/speedyautoloot)
* dtabacaru's [Clam Pulp](https://www.curseforge.com/wow/addons/clam-pulp)
* Xarano's [Faster Loot](https://www.curseforge.com/wow/addons/faster-loot)
* Efron's [LockboxLVL](https://www.curseforge.com/wow/addons/lockboxlvl)