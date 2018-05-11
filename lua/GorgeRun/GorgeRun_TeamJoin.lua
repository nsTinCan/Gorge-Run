if Server then
    function JoinRandomTeam(player)
            Server.ClientCommand(player, "jointeamtwo")
    end
    function TeamJoin:OnTriggerEntered(enterEnt, triggerEnt)
        if enterEnt:isa("Player") then
            if self.teamNumber == kTeamReadyRoom then
                Server.ClientCommand(enterEnt, "spectate")
            elseif self.teamNumber == kTeam1Index then

            ----------------------------------------------------------------------------------------------------
                // Convert the seconds to a common time representation
                local minutes = math.floor(enterEnt:GetResources()/60)
                local seconds = enterEnt:GetResources() - minutes*60
                local GRMessage1 = string.format("%s completed the course. Total Time: %d:%02d",enterEnt:GetName(),minutes, seconds) 
                local GRMessage2 = "Type grstats in console for top scores"

                Print(GRMessage1)
                Print(GRMessage2)
                -- Server.SendNetworkMessage(enterEnt, "Chat", BuildChatMessage(false, "", -1, -1, kNeutralTeamType, GRMessage1), true)
                Server.SendNetworkMessage("Chat", BuildChatMessage(false, "", -1, -1, kNeutralTeamType, GRMessage1), true)
                Server.SendNetworkMessage(enterEnt, "Chat", BuildChatMessage(false, "", -1, -1, kNeutralTeamType, GRMessage2), true)

                local mapname = Shared.GetMapName()
                local grfilename = string.format("config://%s.grstats", mapname)
                local grstatsline = {}
                local oldgrstatsline = {}
                local grstats = io.open( grfilename, "r" )

                if not grstats then --no file so load defaults and loadup up oldgr... in case an update is needed
                    for i= 1,30,3 
                        do 
                            grstatsline[i] = "3540"	
                            oldgrstatsline[i] = "3540"	
                            grstatsline[i+1] = "TinCan"	
                            oldgrstatsline[i+1] = "TinCan"	
                            grstatsline[i+2] = "x_xxxxx"	
                            oldgrstatsline[i+2] = "x_xxxxx"	
                        end
                else
                
                    local i = 1
                    for line in grstats:lines() do
                        grstatsline[i] = line
                        oldgrstatsline[i] = line 
                        i = i + 1
                    end 
                grstats:close()
                end 


                if tonumber(enterEnt:GetResources()) <= tonumber(grstatsline[28]) then
                    local grc = 25 -- Setup counter
                    local playerexistsflag = false
   	                local exitConditionVariable = false
                    local existingtopspot = false
                    -- Check if player exists already
                    for i=3,30,3 
                    do 
                    if tonumber(grstatsline[i]) == tonumber(enterEnt:GetSteamId()) then -- playerid then
                        if tonumber(enterEnt:GetResources()) <= tonumber(grstatsline[i-2]) then
                                grc =  i - 2
                                if grc == 1 then
                                    existingtopspot = true
                                end    
                                playerexistsflag = true
                        else
                                local GRMessage1 = "Great time. But not your best on this map. Try again!" 
                                Print(GRMessage1)
                                Server.SendNetworkMessage(enterEnt, "Chat", BuildChatMessage(false, "", -1, -1, kNeutralTeamType, GRMessage1), true)
                                exitConditionVariable = true
                        end
                    end    
                end


                while not exitConditionVariable do
                    
                    if playerexistsflag == false then   
                        -- Move records down three at a time
                        grstatsline[grc+3] = oldgrstatsline[grc]
                        grstatsline[grc+4] = oldgrstatsline[grc+1]
                        grstatsline[grc+5] = oldgrstatsline[grc+2]
                     end   
                       


                    if existingtopspot == true then
                            grstatsline[grc] = enterEnt:GetResources() 
                            grstatsline[grc+1] = enterEnt:GetName()
                            grstatsline[grc+2] = enterEnt:GetSteamId() 
                            exitConditionVariable = true -- Done, no need to upate further                                       

                    else
                            if tonumber(enterEnt:GetResources()) >= tonumber(oldgrstatsline[grc-3]) then 
                                grstatsline[grc] = enterEnt:GetResources() 
                                grstatsline[grc+1] = enterEnt:GetName()
                                grstatsline[grc+2] = enterEnt:GetSteamId()
                                exitConditionVariable = true -- Done, no need to upate further
                            end
                    end


                           
                        grc = grc - 3

                        playerexistsflag = false  
                        if grc == 1 and exitConditionVariable == false then
                            -- Top score so move down one more time and insert here
                            grstatsline[grc+3] = oldgrstatsline[grc]
                            grstatsline[grc+4] = oldgrstatsline[grc+1]
    	                    grstatsline[grc+5] = oldgrstatsline[grc+2]

                            grstatsline[grc] = enterEnt:GetResources() 
                            grstatsline[grc+1] = enterEnt:GetName()
                            grstatsline[grc+2] = enterEnt:GetSteamId()
                            exitConditionVariable = true -- Done
                        end
                    end
                end

                local ccheck4grfile = io.open(grfilename,"w")
    	            for i = 1,30 do
    	                if grstatsline[i] == nil then -- Just in case?
                            grstatsline[i] = "10101010"
                        end    
                        ccheck4grfile:write(grstatsline[i],"\n")
	                end
                    ccheck4grfile:close()
            
                -- all done so send player to readyroom
                Server.ClientCommand(enterEnt, "readyroom")
--------------------------------------------------------------------------------------                
            elseif self.teamNumber == kTeam2Index then
                Server.ClientCommand(enterEnt, "jointeamtwo")
            elseif self.teamNumber == kRandomTeamType then
                JoinRandomTeam(enterEnt)
            end
        end
    end
end
