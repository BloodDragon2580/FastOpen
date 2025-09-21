-- settings/shard.lua
-- FastOpen Modul: Coffer Key Shards (245653)

local shardID = 245653
local iconPath = "Interface\\Icons\\inv_gizmo_hardenedadamantitetube" -- Dein Icon

if not FastOpen or not FastOpen.AddItem then return end

FastOpen:AddItem({
    id = shardID,
    name = "Coffer Key Shard",
    minCount = 100,  -- Button wird erst angezeigt ab 100 Shards
    icon = iconPath,
    onClick = function()
        local shardCount = GetItemCount(shardID)
        local timesToUse = math.floor(shardCount / 100)
        for i = 1, timesToUse do
            UseItemByID(shardID) -- Wandelt 100 Shards in 1 Schlüssel um
        end
    end,
    postCreate = function(button)
        -- Button optisch wie andere Loot-Kisten anpassen
        button:SetSize(36, 36)  -- Standardgröße der FastOpen Buttons
        button.icon:SetTexture(iconPath)
        button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
})
