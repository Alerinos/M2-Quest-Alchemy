-- Author Alerino
-- Server Atonis.pl
-- Version 1.0
-- Date 08.10.2019

quest alchemy begin
    state start begin
        
        -- Funkcja różnicy lvl zależna od poziomu gracza
        function count(level)
            local count = 0
            
            if level >= 30 and level < 40 then
                if pc.ispremium() then count = 6 else count = 4 end
            elseif level >= 40 and level < 50 then
                if pc.ispremium() then count = 9 else count = 6 end
            elseif level >= 50 and level < 60 then
                if pc.ispremium() then count = 12 else count = 8 end
            elseif level >= 60 and level < 70 then
                if pc.ispremium() then count = 15 else count = 10 end
            elseif level >= 70 and level < 80 then
                if pc.ispremium() then count = 18 else count = 12 end
            elseif level >= 80 and level < 90 then
                if pc.ispremium() then count = 21 else count = 14 end
            elseif level >= 90 and level < 100 then
                if pc.ispremium() then count = 24 else count = 16 end
            elseif level >= 100 and level < 110 then
                if pc.ispremium() then count = 27 else count = 18 end
            elseif level >= 110 then
                if pc.ispremium() then count = 30 else count = 20 end
            end
            
            return count
        end
    
        -- FIX, jeżeli zmieni się data.
        function reload()
            local dateTime = os.time({year=os.date("%Y"), month=os.date("%m"), day=os.date("%d"), hour=0, min=0, sec=0})
            if pc.getqf("date") ~= dateTime then
                pc.setqf("date", dateTime)
                pc.setqf("countDrop", 0)
            end
        end
    
    
        -- Otrzymanie możliwości używania alchemi
        when login or levelup begin
            if pc.get_level() >= 30 and ds.is_qualified() == 0 then
                ds.give_qualification()
            end
            
            -- alchemy.reload()
        end
        
        when kill with not npc.is_pc() begin
            -- Config
            local item = 30270                                  -- Przedmiot jaki dropi
            local itemExchange = 50255                          -- Przedmiot w jaki zmienia się drop
            local limit = alchemy.count(pc.get_level())         -- Dzienny limit
            local minLevel = 30                                 -- Minimalny poziom gracza
            
            local min = npc.get_level0() - 15
            local max = npc.get_level0() + 15
            local lvl = pc.get_level()
        
            if lvl >= min and lvl <= max and math.random(100) <= 1 and pc.get_level() >= minLevel and npc.get_level0() >= minLevel then
                local countDrop = pc.getqf("countDrop")
                local dateTime = os.time({year=os.date("%Y"), month=os.date("%m"), day=os.date("%d"), hour=0, min=0, sec=0})
                
                -- Jeżeli jest ten sam dzień
                if pc.getqf("date") == dateTime then
                    
                    -- Jeżeli otrzymałeś mniej niż x szt
                    if countDrop <= limit then
                        pc.give_item2(item) -- Otrzymuje zwykły przedmiot
                        
                        -- Otrzymuje przedmiot specjalny
                        if pc.count_item(item) >= 10 then
                            pc.remove_item(item, 10)
                            pc.setqf("countDrop", countDrop + 1)
                            pc.give_item2(itemExchange)
                            syschat(prefix.info .."Otrzymałeś "..item_name(itemExchange).." "..(countDrop + 1).."/"..limit.." z limitu dziennego")
                        end
                    end
                    
                -- Jeżeli jest inny dzień
                else
                    pc.setqf("date", dateTime)
                    pc.setqf("countDrop", 0)
                end
            end
            
        end
        
        -- Alchemia
		when 20001.chat."Informacja" begin
		    alchemy.reload()
		    
		    say_title("Informacja")
		    say("Twój dzisiejszy limit wynosi "..pc.getqf("countDrop").."/"..alchemy.count(pc.get_level())..".")
		    say("")
		    say("Każdy poziom ma inny limit.")
		    say("")
		    say("Restart następuje o 24:00 każdego dnia.")
		    say("Obecna godzina "..os.date("%H:%M:%S"))
		    say()
		end
		when 20001.chat."Sklep" begin
		    setskin(NOWINDOW)
		    npc.open_shop(20001)
		end

		when 20001.chat."Uszlachetnienie" begin
		    setskin(NOWINDOW)
		    ds.open_refine_window()
		end
        
    end
end