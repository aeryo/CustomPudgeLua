CustomPudgeLua
==============

Lua code for custom pudge spells

Currently implemented into Frota.

Code changed in Frota:

* in FrotaGameMode:_SetInitialValues:  CustomPudge:InitGameMode() -- To get start up the CustomPudge class
* in gamemodes: local hookSkill = 'pudge_meat_hook_holdout' -- To set the custom hook instead of the base hook

Other:

* Added pudge to herolist to spawn a hero for testing
