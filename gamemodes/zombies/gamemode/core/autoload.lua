resource.AddWorkshop( "128093075" ) -- M9k
resource.AddWorkshop( "128091208" ) -- M9k
resource.AddWorkshop( "128089118" ) -- M9k
resource.AddWorkshop( "144982052" ) -- M9k
resource.AddWorkshop( "3253565670" ) -- Zombies Contentpack

// only download the current map
local current_map = game.GetMap()
for _, v in ipairs(ZConfig.maps) do
    if v.map == current_map then
        resource.AddWorkshop( v.id )
    end
    break
end

// MATRIX