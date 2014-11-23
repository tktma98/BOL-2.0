

local version = "2.06"
local scriptname = "Soraka Pred 2.0"
local autor = "Isexcats"
--

local AARange = 550
local QRange, QSpeed, QDelay, QWidth = 900, 1500, 0.5, 110
local WRange, WDelay = 550, 0.5
local ERange, ESpeed, EDelay, EWidth = 660, 902, 0.5, 100
local RDelay = .5
local RRangeCut = 1200
local QReady, WReady, EReady, RReady = false, false, false, false
local possibleks1, possibleks2, possibleks3, possibleks4 = false, false, false, false


local QHitPRE = 2
local EHitPRE = 2
local lastSkin = 0
local dmg = {}
local ksannouncerrange = 2000
local allyHeroes = {}

local TS = TargetSelector(TargetSelector_Mode.LESS_CAST, TargetSelector_DamageType.MAGIC) 

local whitelistrange = 1700 


Callback.Bind("GameStart", function()

     OnLoad()
     Callback.Bind("Draw", function() OnDraw() end)
     Callback.Bind("Tick", function() OnTick() end)
    
end)

function OnLoad()
    if myHero.charName ~= "Soraka" then return end
     Soraka_harass_tables()
     
     Soraka = MenuConfig ("SorakaPred") 
     
        Soraka:Menu("Prediction","[Prediction Options]")
          Soraka.Prediction:Section("info0","Combo")
          Soraka.Prediction:Slider("QHitCOM", "Q Hitchance", 2, 0, 2)
          Soraka.Prediction:Slider("EHitCOM", "E Hitchance", 2, 0, 2)
          Soraka.Prediction:Section("info1","Harass")
          Soraka.Prediction:Slider("QHitHAR", "Q Hitchance", 2, 0, 2)
          Soraka.Prediction:Slider("EHitHAR", "E Hitchance", 2, 0, 2)
          Soraka.Prediction:Section("info2","HITCHANCE:")
          Soraka.Prediction:Section("info3","Faster <- NORMAL = 1  HIGH = 2 -> Slower")
          

          
        
               
        Soraka:Menu("ComboSettings","[Combo]")
          Soraka.ComboSettings:Boolean("Q","Use Q", true)
          Soraka.ComboSettings:Boolean("E","Use E", true)
          

          
          Soraka:Menu("HarassSettings","[Harass]")
          Soraka.HarassSettings:Boolean("Q","Use Q", true)
          Soraka.HarassSettings:Boolean("E","Use E", false)
          Soraka.HarassSettings:Boolean("R","Use R", true)
          Soraka.HarassSettings:Slider("ManaSliderHarass", "Use mana till (%)", 40, 0, 100)
          Soraka.HarassSettings:Section("info1","Harass White List:")
          
          Soraka.HarassSettings:Boolean("UseWhiteList","Use White List", true)
          Soraka.HarassSettings:Boolean("whitelistexception","exception if White List Out Of Range", true)
          Soraka.HarassSettings:Separator()
          
          for i = 1, Game.HeroCount() do
               local hero = Game.Hero(i)
                    if hero.team == TEAM_ENEMY then
                         if whitelisted[""..hero.charName..""] == true then 
                         Soraka.HarassSettings:Boolean(hero.charName,hero.charName, true)
                         end       
                         if whitelisted[""..hero.charName..""] == nil then
                         Soraka.HarassSettings:Boolean(hero.charName,hero.charName, false)
                         end 
                    end
          end       
                    
     	Soraka:Menu("autoheals", "[Auto Heal]")
     	Soraka.autoheals:Boolean("UseHeal", "Auto Heal Allies",  true)
        Soraka.autoheals:Slider("HealManager", "Heal allies under",  65, 0, 100, 0)
        Soraka.autoheals:Slider("HPManager", "Don't heal under (my hp)", 50, 0, 100, 0)

          Soraka:Menu("ult", "[Ultimate]")
		Soraka.ult:Boolean("UseUlt", "Use ult",  true)
        Soraka.ult:Slider("UltManager", "Ultimate allies under", 25, 0, 100, 0)





          Soraka:Menu("KS","[KS Options]")
          Soraka.KS:Boolean("Enable","Enable KS", true)
          Soraka.KS:Boolean("AA","KS with AA", true)
          Soraka.KS:Boolean("Q","KS with Q", true)
          Soraka.KS:Boolean("E","KS with E", true)

          Soraka:Menu("Draws","[Draws]")
          
          Soraka.Draws:Boolean("Announcer","Kill Announcer", true)
        Soraka.Draws:Boolean("AA","Draw AA Range", true)
        Soraka.Draws:Boolean("Q","Draw Q Range", false)
        Soraka.Draws:Boolean("W","Draw W Range", false)
        Soraka.Draws:Boolean("E","Draw E Range", false)
        Soraka.Draws:Boolean("R","Draw R Range", false)

        Soraka:Section("Binds","Key Bindings")
          Soraka:KeyBinding("Combo","Combo", "SPACE")
        Soraka:KeyBinding("Harass1","Harass 1", "C")
        Soraka:KeyBinding("Harass2","Harass 2", "X")
          
          Soraka:Section("about1",scriptname)
          Soraka:Section("about2","v: "..version)




     
     Game.Chat.Print("<font color='#c9d7ff'>"..scriptname..": </font><font color='#64f879'> v. "..version.." </font><font color='#c9d7ff'> loaded </font>")   
     BasicPrediction.EnablePrediction()
     
end

function OnTick()

     Target = TS:GetTarget(1500)
     AutoUltimate()
     dmg2screen()
     if Soraka.ult.UseUlt:Value() then
     		AutoUltimate()
     end
     
     if Soraka.KS.Enable:Value() then
     KS()
     end 
     if possibleks1 == false and possibleks2 == false and possibleks3 == false and possibleks4 == false then
          if Soraka.Combo:IsPressed() then         
          Combo()
          end 
          
          if Soraka.Harass1:IsPressed() or Soraka.Harass2:IsPressed() then 
          Harass()
          end 
     end
     if Soraka.autoheals.UseHeal:Value() then
     	AutoHeal()
     end
end 

local QReady = function() return (myHero:CanUseSpell(0) == Game.SpellState.READY) end
local WReady = function() return (myHero:CanUseSpell(1) == Game.SpellState.READY) end
local EReady = function() return (myHero:CanUseSpell(2) == Game.SpellState.READY) end
local RReady = function() return (myHero:CanUseSpell(3) == Game.SpellState.READY) end


function KS()

  for i = 1, Game.HeroCount() do
    local hero = Game.Hero(i)
     if hero.team == TEAM_ENEMY then
          if not hero.dead and hero.visible and hero ~= nil then

               if Soraka.KS.Q:Value() and QReady() and hero.health < SpellDamage.GetDamage("Q",hero,myHero) and myHero:DistanceTo(hero) < QRange and myHero.mana >= SorakaMana(Q) then 
               possibleks1 = true
               local QHitPRE = 2
               CastQ(hero)
               else
               possibleks1 = false
               end 
               if Soraka.KS.E:Value() and EReady() and hero.health < SpellDamage.GetDamage("E",hero,myHero)  and myHero.mana >= SorakaMana(E) then 
               possibleks2 = true
               local EHitPRE = 2
               CastE(hero)
               else
               possibleks2 = false
               end 
               if Soraka.KS.Q:Value() and Soraka.KS.E:Value() and QReady() and EReady() and hero.health < SpellDamage.GetDamage("Q",hero,myHero) + SpellDamage.GetDamage("E",hero,myHero) and myHero:DistanceTo(hero) < QRange and myHero.mana >= SorakaMana(QE) then 
               possibleks3 = true
               local QHitPRE = 2
               local EHitPRE = 2
               CastQ(hero)
               CastE(hero)
               else
               possibleks3 = false
               end  
               
               if Soraka.KS.AA:Value() and hero.health < SpellDamage.GetDamage("AD",hero,myHero) + SpellDamage.GetDamage("P",hero,myHero) and myHero:DistanceTo(hero) < 650 then 
               possibleks4 = true
               myHero:Attack(hero)
               else
               possibleks4 = false
               end 
               
          else
          possibleks1, possibleks2, possibleks3, possibleks4 = false, false, false, false
          end
     end
     end
end 

function Combo()
if not Target then return end
     if Target and Target.valid and Target.visible and Target.team ~= myHero.team and not Target.dead then
     
          if QReady() and Soraka.ComboSettings.Q:Value() and myHero:DistanceTo(Target) < QRange then 
          local QHitPRE = Soraka.Prediction.QHitCOM:Value()
          CastQ(Target)
          end
          if EReady() and Soraka.ComboSettings.E:Value() and myHero:DistanceTo(Target) < ERange then 
          myHero:CastSpell(Game.Slots.SPELL_3, Target.x, Target.z)
          end 
         
     end  

end 

function Harass()
if not Target then return end
     if not SorakaManaislowerthen(Soraka.HarassSettings.ManaSliderHarass:Value()) then
     
          if Soraka.HarassSettings.UseWhiteList:Value() then
               for i = 1, Game.HeroCount() do
                    local hero = Game.Hero(i)
                         if hero.team == TEAM_ENEMY then
                         if Soraka.HarassSettings[hero.charName] then
                         
                              if myHero:DistanceTo(hero) < whitelistrange then
                                   if hero and hero.valid and hero.visible and hero.team ~= myHero.team and not hero.dead then
                                        if QReady() and Soraka.HarassSettings.Q:Value() and myHero:DistanceTo(hero) < QRange then 
                                        local QHitPRE = Soraka.Prediction.QHitHAR:Value()
                                        CastQ(hero)
                                        end
                                          if EReady() and Soraka.HarassSettings.E:Value() and myHero:DistanceTo(hero) < ERange then 
                                        local EHitPRE = Soraka.Prediction.QHitHAR:Value()
                                        CastE(hero)
                                        end
                                        
                                   end       
                              else 
                              if hero.dead or not hero.visible then
                                   if Soraka.HarassSettings.whitelistexception:Value() then
                                        if Target and Target.valid and Target.visible and Target.team ~= myHero.team and not Target.dead then
                                        
                                             if QReady() and Soraka.HarassSettings.Q:Value() and myHero:DistanceTo(Target) < QRange then 
                                             local QHitPRE = Soraka.Prediction.QHitHAR:Value()
                                             CastQ(Target)
                                             end
                                             if EReady() and Soraka.HarassSettings.E:Value() and myHero:DistanceTo(hero) < ERange then 
                                        	 local EHitPRE = Soraka.Prediction.QHitHAR:Value()
                                       		 CastE(hero)
                                        	 end


                                             
                                             
                                        end 
                                   end
                              end
                              end
                              
                         end
                         
                         
                         end
               end
          
          end 
          if not Soraka.HarassSettings.UseWhiteList:Value() then
               if Target and Target.valid and Target.visible and Target.team ~= myHero.team and not Target.dead then
               
                    if QReady() and Soraka.HarassSettings.Q:Value() and myHero:DistanceTo(Target) < QRange then 
                    local QHitPRE = Soraka.Prediction.QHitHAR:Value()
                    CastQ(Target)
                    end
                    
               end  
          end
          
     end
end 



function AutoHeal()
        for _, ally in ipairs(allyHeroes) do
            if WReady and Soraka.autoheals.UseHeal then
                if (ally.health / ally.maxHealth < Soraka.autoheals.HealManager /100) and (myHero.health / myHero.maxHealth > Soraka.autoheals.HPManager /100) then
                    if myHero:DistanceTo(ally) < WRange then
                    	Game.Chat.Print("done")
                            myHero:CastSpell(1, ally)
                        end
                    end
                end
            end
        end

function AutoUltimate()
        for _, ally in ipairs(allyHeroes) do

            ------------------------------
            if ally.dead then return end
            if myHero.dead then return end
            ------------------------------

            if SpellTable[_R].ready and Soraka.ult.UseUlt then
                
                    if (ally.health / ally.maxHealth < Soraka.ult.UltManager /100) then
                                myHero:CastSpell(3)
                            end
                      
            end
        end
    end
  

function CastQ(unit)
     local PPos, HC  = BasicPrediction.GetPredictedPosition(unit, QRange, QSpeed, QDelay, QWidth, false, false, myHero)
     if PPos and PPos.x and PPos.y and PPos.z and HC >= QHitPRE then
     myHero:CastSpell(Game.Slots.SPELL_1, PPos.x, PPos.z)
     end
end  

function CastE(unit)
     local PPos, HC  = BasicPrediction.GetPredictedPosition(unit, ERange, ESpeed, EDelay, EWidth, false, false, myHero)
     if PPos and PPos.x and PPos.y and PPos.z and HC >= EHitPRE then
     myHero:CastSpell(Game.Slots.SPELL_1, PPos.x, PPos.z)
     end
end  


     
function OnDraw()
     if not myHero.dead then
          if Soraka.Draws.AA:Value() then
          Graphics.DrawCircle(myHero, AARange, Graphics.ARGB(0xFF,0,0xFF,0))
          end 
          if Soraka.Draws.Q:Value() then
          Graphics.DrawCircle(myHero, QRange, Graphics.ARGB(0xFF,0,0xFF,0))
          end 
          if Soraka.Draws.W:Value() then
          Graphics.DrawCircle(myHero, WRange, Graphics.ARGB(0xFF,0,0xFF,0))
          end 
          if Soraka.Draws.E:Value() then
          Graphics.DrawCircle(myHero, ERange, Graphics.ARGB(0xFF,0,0xFF,0))
          end 
         
          
          
               for i = 1, Game.HeroCount() do
               local hero = Game.Hero(i)
               local screenpos = Graphics.WorldToScreen(hero.pos)
               if hero.team == TEAM_ENEMY then
                    if not hero.dead and hero.visible and hero ~= nil and myHero:DistanceTo(hero) < ksannouncerrange then
                         if dmg[i] ~= nil and Soraka.Draws.Announcer:Value() then
                         Graphics.DrawText((dmg[i]), 20, screenpos.x, screenpos.y, Graphics.ARGB(255,0,255,0))          
                         end 
                    end
               end
               end
     else
     dmg[i] = nil
     end
end 

function dmg2screen()

     for i = 1, Game.HeroCount() do
          local hero = Game.Hero(i)
          if hero.team == TEAM_ENEMY then
               if not hero.dead and hero.visible and hero ~= nil and myHero:DistanceTo(hero) < ksannouncerrange then
               
                    if hero.health < SpellDamage.GetDamage("AD",hero,myHero) + SpellDamage.GetDamage("P",hero,myHero) then
                    dmg[i] = "possible kill: AA"
                    elseif QReady() and hero.health < SpellDamage.GetDamage("Q",hero,myHero) and myHero.mana >= SorakaMana(Q) then
                    dmg[i] = "possible kill: Q"
                    elseif QReady() and hero.health < SpellDamage.GetDamage("AD",hero,myHero) + SpellDamage.GetDamage("P",hero,myHero) + SpellDamage.GetDamage("Q",hero,myHero) and myHero.mana >= SorakaMana(Q) then
                    dmg[i] = "possible kill: Q + AA"
                    elseif EReady() and hero.health < SpellDamage.GetDamage("E",hero,myHero) and myHero.mana >= SorakaMana(E) then
                    dmg[i] = "possible kill: E"
                    elseif EReady() and QReady() and hero.health < SpellDamage.GetDamage("E",hero,myHero) + SpellDamage.GetDamage("Q",hero,myHero) and myHero.mana >= SorakaMana(QR) then
                    dmg[i] = "possible kill: Q + E"
                    elseif RReady() and QReady() and hero.health < SpellDamage.GetDamage("E",hero,myHero) + SpellDamage.GetDamage("Q",hero,myHero) + SpellDamage.GetDamage("AD",hero,myHero) + SpellDamage.GetDamage("P",hero,myHero) and myHero.mana >= SorakaMana(QE) then
                    dmg[i] = "possible kill: Q + E + AA"
                    else
                    dmg[i] = nil
                    end 

               else
               dmg[i] = nil
               end
               
          end
                    
     end
end 

function SorakaMana(spell)
     if spell == Q then
          return 70 + (5 * myHero:GetSpellData(0).level)
     elseif spell == E then
          return 70
     elseif spell == QE then
          return 70 + (10 * myHero:GetSpellData(2).level) + 70
     
     end
end  
function SorakaManaislowerthen(percent)
    if myHero.mana < (myHero.maxMana * ( percent / 100)) then
        return true
    else
        return false
    end
end

function Soraka_harass_tables()
     whitelisted={}
      whitelisted["Ashe"] = true
     whitelisted["Caitlyn"] = true
     whitelisted["Soraka"] = true
     whitelisted["Draven"] = true
     whitelisted["Ezreal"] = true
     whitelisted["Graves"] = true
     whitelisted["Jinx"] = true
     whitelisted["KogMaw"] = true
     whitelisted["Lucian"] = true
     whitelisted["MissFortune"] = true
     whitelisted["Quinn"] = true
     whitelisted["Sivir"] = true
     whitelisted["Tristana"] = true
     whitelisted["Twitch"] = true
     whitelisted["Urgot"] = true
     whitelisted["Varus"] = true
     whitelisted["Vayne"] = true
end
