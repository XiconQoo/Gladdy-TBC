# Gladdy - TBC

### The most powerful arena addon for WoW TBC 2.5.1
## [v1.12-Beta Download Here](https://github.com/XiconQoo/Gladdy-TBC/releases/download/v1.12-Beta/Gladdy_TBC-Classic_v1.12-Beta.zip)

###### <a target="_blank" rel="noopener noreferrer" href="https://www.paypal.me/xiconqoo/10"><img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/Paypal-Donate.png" height="30" style="margin-top:-30px;position:relative;top:20px;"></a> Please consider donating if you like my work

### Origin

Based on https://github.com/Schaka/gladdy

### Motivation for this edit

The goal is to make Gladdy highly configurable in it's appearance. Everything can be arranged left or right independently. Also I gave Gladdy a new look with black borders. A lot can be configured.

### Modules:
- Announcement (drink, trinket usage, spec detection ...)
- ArenaCountDown
- Auras (show important (de)buffs in the class icon)
- BuffsDebuffs (show buffs and debuffs on arena frames - can be filtered)
- ClassIcon (or specicon, once detected)
- CombatIndicator 
- Cooldown (tracks important cooldowns)
- Diminishing (tracks DRs)
- ExportImport (share your profile with your friends in the form of a string, which can be imported)
- Highlight (highlights focus and target)
- Pets (show arena pets)
- Racial Spells
- Range Check
- Shadowsight Timer
- TotemPlates (show totem icons instead of normal nameplates)
- Trinket (tracks trinket usage)
- VersionCheck (checks if you use an older version that your teammate)
- XiconProfiles (predefined profiles to start your configuration from)

## Screenshots

<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample1.jpg">
<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample2.jpg" align="right" width="48.5%">
<img src="https://raw.githubusercontent.com/XiconQoo/Gladdy/readme-media/sample3.png" width="48.5%">

## Special Thanks

- **Schaka** - the original author of Gladdy! (thanks for letting me continue Gladdy and all the work you put into the TBC community)
- **Macumba** (thanks for all the support, your feedback and your dedication for the TBC community)
- **RMO** (without you I would not have modified Gladdy at all and thanks for all the suggestions and active feedback)
- **Ur0b0r0s aka DrainTheLock** (thanks for testing, giving feedback and correcting/adding wrong CDs)
- **Klimp** (thanks for all the suggestions and active feedback)
- **the whole TBC addons 2.4.3 discord** (thanks for the support and great community, especially the MVPs)
- **Hydra** (thanks for constructive feedback and suggestions)

### Changes

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