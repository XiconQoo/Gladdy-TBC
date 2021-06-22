# Gladdy - TBC

### The most powerful arena addon for WoW TBC 2.5.1
## [v1.16-Beta Download Here](https://github.com/XiconQoo/Gladdy-TBC/releases/download/v1.16-Beta/Gladdy_TBC-Classic_v1.16-Beta.zip)

###### <a target="_blank" rel="noopener noreferrer" href="https://www.paypal.me/xiconqoo/10"><img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/Paypal-Donate.png" height="30" style="margin-top:-30px;position:relative;top:20px;"></a> Please consider donating if you like my work

### Origin

Based on https://github.com/miraage/gladdy

### Motivation for this edit

The goal is to make Gladdy highly configurable in it's appearance. Everything can be arranged left or right independently. Also I gave Gladdy a new look with black borders. A lot can be configured.

### Modules:
- **Announcement** (drink, trinket usage, spec detection ...)
- **ArenaCountDown**
- **Auras** (show important (de)buffs as well as interrupts on the class icon)
- **BuffsDebuffs** (show buffs and debuffs on arena frames - can be filtered)
- **CastBar** (shows a castbar, can be disabled)
- **ClassIcon** (or specicon, once detected)
- **Clicks** (bind spells or macros to click actions)
- **CombatIndicator** (shows a sword icon if unit is in combat)
- **Cooldown** (tracks important cooldowns)
- **Diminishing** (tracks DRs)
- **ExportImport** (share your profile with your friends in the form of a string, which can be imported)
- **Highlight** (highlights focus and target)
- **Pets** (show arena pets)
- **Racial** (show arena racial cooldowns)
- **Range Check** (checks the range to a unit by a configurable spell)
- **Shadowsight Timer** (shows a little movable frame with time left until Shadow Eyes spawn)
- **TotemPlates** (show totem icons instead of normal nameplates, compatible with **Plater, NeatPlates, KUI, ThreatPlates, ElvUI, TukUI**)
- **Trinket** (tracks trinket usage)
- **VersionCheck** (checks if you use an older version that your teammate)
- **XiconProfiles** (predefined profiles to start your configuration from)

### Valid Slash commands

- **/gladdy ui** (shows config)
- **/gladdy test** (standard 3v3 test mode)
- **/gladdy test1** to **/gladdy test5** (test mode with 1-5 frames active)
- **/gladdy hide** (hides the frames)
- **/gladdy reset** (resets current profile to default settings)

## Screenshots

<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample1.jpg">
<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample2.jpg" align="right" width="48.5%">
<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample3.png" width="48.5%">

## Special Thanks

- **miraage** - the origininal author of Gladdy! Your work set the foundation for this edit. Thanks!
- **Schaka** - the maintainer of Gladdy! (thanks for letting me continue Gladdy and all the work you put into the TBC community)
- **Macumba** (thanks for all the support, your feedback and your dedication for the TBC community)
- **RMO** (without you I would not have modified Gladdy at all and thanks for all the suggestions and active feedback)
- **Ur0b0r0s aka DrainTheLock** (thanks for testing, giving feedback and correcting/adding wrong CDs)
- **Klimp** (thanks for all the suggestions and active feedback)
- **the whole TBC addons 2.4.3 discord** (thanks for the support and great community, especially the MVPs)
- **Hydra** (thanks for constructive feedback and suggestions)

### Changes

### v1.16-Beta
- unit gray in stealth when rangecheck module disabled

### v1.15-Beta
- hotfix added entangling roots nature's grasp

### v1.14-Beta
- hotfix for secure button grow direction up

### v1.13-Beta
- frames behave now to mouseover macros
- added Range Check module (configurable which spell is used for range check)
- added Shadowsight Timer module (with announce)
- added Clicks module
- added Interrupt Tracker in Aura module (border color by spell school locked)
- TotemPlates compatible with Plater, NeatPlates, KUI, ThreatPlates, ElvUI, TukUI
- added a new Classic Profile in XiconProfiles
- hide blizzard arena frames option added in General
- castbar enable/disable
- powerbar enable/disable
- added some auras (Blackout, Improved Hamstring, Mace Stun, Stormherald Stun, Shadowsight Buff)
- added Swiftmend and Berserker Rage cooldowns
- changed textures for Mace Stun, Charge Stun and Intercept Stun
- reduced BLP size by 80%
- show XiconProfiles on first login
- DR bigger icons possible
- minor fixes

### v1.12-Beta
- fix classic profile

### v1.11-Beta
- TotemPlates fix after blizzard update

### v1.10-Beta
- fix german and russian client not working
- ArenaCountdown loacalization now working for all languages (except itIT...beta has no option to select italian)
- Race and Class localization working for all languages
- Localization finished for German

#### v1.09-Beta
- fix Blizzard profile not having all modules preconfigured

#### v1.08-Beta
- fix Buffs not showing on class icon
- added option highlight to be inside
- added option to grow frames vertically
- added new profile to XiconProfile (Blizzard raid style)
- minor bugfixes

#### v1.07-Beta

- CombatIndicator module added
- spec icon option added to Classicon module
- arena1-5 for name option added
- add a couple buffs to LibClassAuras
- add blessing of sacrifice and intervene to auras
- general options updated to apply font/borders/etc for all frames
- XiconProfiles updated
- /gladdy test1-5 now possible
- fix PowerBar text updates
- click through frames exept health/power bar
- add mask texture for icons

#### v1.06-Beta
- fixed BuffsDebuff module
- fix racial texture reset
- minor bugfixes

#### v1.0.5-Beta
- fixed Aura-Module
- Racial module added to EventListener and Version check updated
- constants for auras/cooldowns/racials updated
- anchoring for modules rewritten
- fix Aura module options (localization independent for profile export)
- Power-/HealthBar customize texts added and UNIT_DESTROYED added
- Racial module added and trinket modified
- XiconProfiles import strings
- Pets position extended
- delete unused saved variables
- ExportImport, VersionCheck & XiconProfiles fix
- TotemPlates add option to show friendly/enemy icons

#### v1.0.4-Beta
- XiconProfiles fixed

#### v1.0.0-Beta
- port form 2.4.3