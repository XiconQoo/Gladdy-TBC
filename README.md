# Gladdy - Macumba / XiCoN Edit

### The most powerful arena addon for WoW TBC 2.4.3
## [v1.3.1-Release Download Here](https://github.com/XiconQoo/Gladdy/releases/download/v1.3.1-Release/Gladdy-MX-Edit-v1.3.1-Release.zip)

###### <a target="_blank" rel="noopener noreferrer" href="https://www.paypal.me/xiconqoo/10"><img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/Paypal-Donate.png" height="30" style="margin-top:-30px;position:relative;top:20px;"></a> Please consider donating if you like my work

### Origin

Based on https://github.com/Schaka/gladdy

### Motivation for this edit

The goal is to make Gladdy highly configurable in it's appearance. Everything can be arranged left or right independently. Also we gave Gladdy a new look with black borders. A lot can be configured. Take a look at the [Changelist](https://github.com/XiconQoo/Gladdy#changes).

The PlateCastBar and TotemPlates module are completely reworked as well. Both are fully configurable and most importantly compatible with **Blizz, 
Aloft, ShaguPlates, SoHighPlates, ElvUI and Plates (by by siggestardust) !**

##### Join the [TBC addons 2.4.3 Discord](https://discord.gg/5qVu56M) by Macumba if you have any questions.


### Recommended addons to use with Gladdy

#### [BuffLib by Schaka](https://github.com/Schaka/BuffLib/releases/download/v1.1.1/BuffLib.zip)

## Screenshots

<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample1.jpg">
<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample2.jpg" align="right" width="48.5%">
<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample3.png" width="48.5%">

### Changes

#### v1.3.1-Release
- **new module XiconProfiles**
  - added basic starter profiles (Classic Gladdy, Knall's & Klimp's profiles)
- fix Deep Wounds tracking in Debuff Module
- some minor adjustments to debuff tracking in general
- icons can be stretched now as well

#### v1.3-Release
- **NEW** module **BuffsDebuffs**!
  - tracks debuffs on gladdy frames
  - highly configurable
  - list for every class let's you configure what debuffs to track
  - by default does not display CC, which is normally shown on class icon (configurable)
  - tracks multiple debuffs of same type (like rupture or corruption)
  - not 100% accurate especially on tracking dispel on two debuffs with the same spellID
- add own LibDebuffDuration-1.0
- add DRData-1.0 and track DR on spell remove and spell refresh
   - added missing DRs like Frostmages Chill effect
- fix Click module (custom macros with placeholder **\*name*** are now possible)
  ```
  /targetexact *name*
  /cast Polymorph
  /targetlasttarget
  ```
- Cooldown fix (thanks DrainTheLock)
- Trinket/Classicon width now adjustable
- added spells to ClassIcon (Unstable Affliction Silence, Starfire Stun)
- add button for Gladdy config in blizz interface options
- highlight border color add alpha
- add icon padding option
- optimizations for less CPU resources
- add Windrunner realm to TrinketTracker ignore list
- force Warriors/Rogues/Hunters on last position (eg arena2 in 2v2 or arena3 in 3v3)

#### v1.2-Release
- fixed castbar timer formats
- added option to show timeleft, total or both to castbars
- option to add a custom TotemName that appears on the totemicons
- cooldowns can be positioned LEFT or RIGHT now as well
- option cooldowns max icons per row added

#### v1.1.2

- fix cooldown numbers reset

#### v1.1

- **`/gladdy ui` opens it's own window now. More space to configure AND movable**
- **global options to style font / border-style / color of frame borders**
- **selfmade borders (best I could do with PS)**
  - all borders can be configured individually as well
  - aura border color for debuff or buff configurable
  - borders registered with SharedMedia
  - cooldown circles can be enabled/disabled
- **font option for all modules**
  - responsive fontscale when changing iconsizes (adjustable)
  - font size for bars is static and configurable
  - fonts registered with SharedMedia
- **rewritten TotemPlates module (highly configurable) - compatible with Blizz, Aloft, Sohighplates, Shaguplates, ElvUI and Plates (by siggestardust)**
  - TotemPlates detects wether ShaguPlates or SoHighPlates own totem icons option is enabled, thus TotemPlates are only active if disabled there
  - TotemPlates module localization with `GetSpellInfo(spellId)` (if server screws up the names, there are fallback-tables) - aims to support localizations outside of enGB
  - totem icons can be individually enabled/disabled and each totem's border color and alpha can be adjusted
  - totem size adjustable
  - option to alter behaviour of totemicons alpha when targeted, not targeted and no target exists
- **rewritten PlateCastBar module (highly configurable)  - compatible with Blizz, Aloft, Sohighplates, Shaguplates, ElvUI and Plates (by siggestardust)**
  - PlateCastBars size, texture, icon size, icon position, border, border color, position, font, fontcolor, enabled font and spell time format adjustable
- ClassIcon and Trinket size adjustable
- ArenaCountdown size adjustable
- Cooldown circles adjustable in alpha or option to enable/disable globally or by module
- added horizontal/vertical offset options to castbars/diminishing returns/cooldowns
- ace library update
- LibSharedMedia working properly
- minor styling issues fixed
- minor bugfixes

#### v1.0-Release
- `/gladdy test` now activates **everything** for maximum configurability
- added black borders to all frames
- added cooldown numbers to all elements (no need to use OmniCC or similar)
- **ALL ELEMENTS** are arrangeable LEFT or RIGHT independently
  - trinket LEFT or RIGHT
  - class icon LEFT or RIGHT
  - DR frames LEFT or RIGHT
  - cast bar and icon LEFT or RIGHT
  - cooldowns TOP or DOWN and LEFT or RIGHT
- everything aligns to each other responsively depending on config (eg if cast bar and DR are on same side, they will arrange each other)
- padding, scaling and margin responsive
- cast bar and icon height/width is configurable
- trinket and class icon are now rectangular
- trinket and class icon scale with health + power bar height
- replaced the class icons with their PNG icons for better frame border
- trinket icon is clickable again (to trigger a cooldown on that target)
- increase max height for health bar to 100px
- added TrinketTracker again (added Endless-realms (Sunstrider/Tournament) to the exclusion list)
- configurable highlight border size
- background color of health-/power-/cast bar configurable