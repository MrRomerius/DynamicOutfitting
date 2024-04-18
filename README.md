# Dynamic Outfitting
**A Fallout 4 mod that gives NPCs the ability to change their outfits.**

Dynamic Outfitting is a simple script-based Fallout 4 mod that adds the ability for NPC characters to change their outfits based on the AI packages they run.
This was my final project for Harvard CS50 last year, but admittedly the original project was something of a hack that was not in any way ready for public consumption.
It had a number of issues originally, all of which stemmed from my novicehood and diving headfirst into a problem that was way above my understanding of other
critical components like the Creation Engine, the Papyrus scripting language, and the engine-level quirks and misfires of a Bethesda game.

## 1.0 beta
This project has gone through at least 4 other iterations in attempts to deal with the limitations and bugginess of the Papyrus scripting language. This beta is the fruit
of several months of growth as a programmer, getting past the initial honeymoon phase of performing magic tricks with functions, and settling into the devotion phase of
dealing with poor documentation, bad code from other devs, and a buttload of research i.e. digging into forum chats from other devs who've dealt with similar problems.

## Design
This mod is designed using a subscription-based model. It uses an event broker script subscribed to other scripts and programmed to listen for their custom events.
When those events fire off, the event broker calls functions on other scripts based on what event it receives. Currently, my mod only works on settler NPCs, but this model allows for
maximum flexibility and easy expansion if we want to increase our scope to include other kinds of NPCs, as well as the player.

Similarly, NPCs given the magic effect object by our mod also subscribe to events from our mod and the base game upon loading to change their clothing based on
the events they're registered to receive, as well as events defined by their native scripts. They unregister soon as they and their magic effect object are fully unloaded.

## Known Issues
- This mod currently only works on settler NPCs. Other NPCs (companions, raiders, BOS, Diamond City residents, etc.) that use beds will be included in future updates.
- Not really an issue, but you might notice a split-second flicker on an NPC if you catch them spawning or after you access their inventory to equip or unequip clothing items.
That's just the mod saving the NPC's equipment. Not a bug.
- No uninstall feature as of yet. This is a beta. Scripts aren't saved by the game, but I don't recommend removing the mod mid-game as it does generate inventory objects for NPCs
and you don't want to use a save that has missing references baked into them. As always, use at your own risk!
