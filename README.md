# DynamicOutfitting
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
maximum flexiblity and easy expansion if we want to expand our scope to include other kinds of NPCs, as well as the player.

## Code of Conduct
If you want to contribue to this project in some way, cool. Just one rule: don't be a jerk. Coding is hard and stressful enough as it is, and I don't have the patience for children
who park their manners outside their computer screens. This is hard shit. Treat yourself and your devs better.

## License
I didn't like any of the licenses on offer from GitHub, so I'll just drop mine here. Consider my license the same as the MIT license, only with one caveat. Attribute me
as the author for whatever code you may find useful for your own scripting projects. A simple pay-it-forward, that's all.
