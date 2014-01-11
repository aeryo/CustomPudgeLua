-- Pudge War
RegisterGamemode('pudgewars', {
    -- Gamemode covers picking and playing
    sort = GAMEMODE_BOTH,
    
    -- Function to give out heroes
    assignHero = function(frota, ply)
    
        -- Change heroes
        ply:ReplaceHeroWith('npc_dota_hero_pudge', 100000, 32400)

        local playerID = ply:GetPlayerID()
        local hero = Players:GetSelectedHeroEntity(playerID)

        -- Apply the build
        frota:ApplyBuild(hero, {
            [1] = 'pudge_meat_hook_holdout',
            [2] = 'pudge_wars_upgrade_hook_damage',
            [3] = 'pudge_wars_upgrade_hook_range',
            [4] = 'pudge_wars_upgrade_hook_speed',
            [5] = 'pudge_wars_upgrade_hook_size'
        })

        hero:__KeyValueFromInt('AbilityLayout', 6)
    end,

    -- A list of options for fast gameplay stuff
    options = {
        -- Kills give team points
        killsScore = true,

        -- Score Limit
        scoreLimit = 10,

        -- Enable scores
        useScores = true,

        -- Respawn delay
        respawnDelay = 3
    }, 
           
    onGameStart = function(frota)
        -- Grab options
        local options = frota:GetOptions()

        -- Set the score limit
        frota:SetScoreLimit(options.scoreLimit)
        
        --Init custom Pudge Wars class
        CustomPudge:InitGameMode()
    end,
    onThink = function(frota, dt) CustomPudge:_thinkState_Move() end
})