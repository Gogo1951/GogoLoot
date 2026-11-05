# GogoLoot // Test Plan

GogoLoot speeds up looting, rolls and opens for you, and hands out loot as master looter. This time we most want you to try the reworked options pages and which containers open by themselves.

**Play on Classic Era, Season of Discovery, TBC Anniversary, WoW Forever and MoP Classic.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. Read the **Example:** lines across the options pages: each matches the chat line it stands for, with a real item and a class-colored name.
2. On the **Openables List**, set a clam to **Ignore**, untick **Enable Automated Opening**, then loot one: chat says it was left in the loot window for you.
3. Loot a soulbound or quest container, one you can't sell: it now opens by itself instead of staying shut.
4. Open **Automated Rolls → Character Rules**: each stat group has its own header, and only the stats your game version uses are listed.
5. Untick **Enable Item Overrides**: a red line on its list says those rolls aren't being used, and any item you add starts on **Manual**.
6. Carry a locked lockbox and hover the mini-map button: under **Locked Items**, a line says who can pick it.
7. On **WoW Forever**, with **Enable Speedy Loot** on, loot a run of mobs one after another: no empty **Items** window is left on screen afterwards.
8. With **Loot Toasts** on, loot a mob with several drops: the rows come in one at a time, each sliding in from the side, and every row stays up until the looting stops. Each icon has a frame in its quality's color (coin's is black) with rounded corners, the icon fills the row's height, and a dark shade behind the row fades out just past the text. Try it with the stack aligned right too, and at a small and a large font size: the corners stay round and the frame stays even.
9. Loot an Epic (purple) item: its toast flashes purple for a moment.
10. With your bags almost full, loot cloth or potions you already carry a part stack of: they're still picked up. A Hunter's arrows go into the quiver, even with every other bag full.
11. With your bags full, loot a mob: anything that won't fit stays in the loot window for you, and coin is still taken. If a pickup is refused after the window has closed (looting several mobs fast with only a few slots free), chat says some loot was left on the corpse, with the reason.
12. With **ElvUI** or **Tukui** (their loot window turned on) and **Enable Speedy Loot**, loot a mob: no loot window flashes up. Then loot a Bind on Pickup item: their loot window stays up for it.
13. On **MoP Classic**, earn Justice or Valor Points: a toast shows the currency and how much, and **Loot Toasts → Filters** has a **Currency** row that turns it off.

## Everything Else

14. With **Enable Speedy Loot** on, loot a mob: everything lands in your bags with no loot window flashing up.
15. Tick **Enable Automated Rolls** and, in a party on Group Loot, let a green drop: GogoLoot Greeds it and names the item in chat.
16. Loot a clam or other container: it opens by itself, but never in combat or mid-cast; on WoW Forever, try this in a fight.
17. On a Rogue, loot a locked lockbox and pick its lock: it opens by itself.
18. As master looter with **Enable Automated Master Looting** on, pick a player under **Loot Destinations**: the loot goes to them.
19. Trade a friend: they get one whisper listing everything that changed hands.
20. Type `/gogo`, then **Shift + Middle-Click** the mini-map button: both open GogoLoot inside the game's Options window, TBC Anniversary included.
21. In combat, type `/gogo`: chat says the options can't open during combat, and they stay shut.
