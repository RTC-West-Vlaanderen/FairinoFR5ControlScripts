CloseSocketConnect(0);
OpenSocketConnect(0)
SocketSend(0, "READY", 1)
gripper_open = false
ActGripper(2,0)
ActGripper(2,1)
local function clean_text(v)
    if v == nil then
        return nil
    end

    local s = tostring(v)
    s = string.gsub(s, "\r", "")
    s = string.gsub(s, "\n", "")
    s = string.gsub(s, "%z", "")
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")

    if s == "" then
        return nil
    end

    return s
end

while true do
    local _, b = SocketReceive(0, 200, 1)
    local text = clean_text(b)

    if text ~= nil then
        SocketSend(0, "B=[" .. text .. "]", 1)
        local rcvMessage = string.lower(text)
        if rcvMessage == "home" then
            SocketSend(0, "ACK_HOME", 1)
            PTP(pHome, 100, -1, 0)
        end
        if rcvMessage == "grabbefore" then
            SocketSend(0, "ACK_GRABBEFORE", 1)
            PTP(grabpbefore, 100, -1, 0)
        end
        if rcvMessage == "opengripper" then
           SocketSend(0, "ACK_OPENGRIPPER", 1)
            MoveGripper(2, 0, 100, 0, 30000, 0, 0, 0, 0, 0)
        
            -- Poll tot beweging klaar is (max 5 seconden)
            local done = 0
            for i = 1, 50 do
                local err, d = GetGripperMotionDone(2)
                if d == 1 then
                    done = 1
                    break
                end
                WaitMs(100)
            end
        
            if done == 1 then
                gripper_open = true
                SocketSend(0, "GRIPPER:OPEN:CONFIRMED", 1)
            else
                SocketSend(0, "GRIPPER:OPEN:TIMEOUT", 1)
            end
        end
        if rcvMessage == "grabpoint" then
            SocketSend(0,"ACK_GRABPOINT",1)
            PTP(grabp,100,-1,0)
        end
        if rcvMessage == "closegripper" then
            SocketSend(0, "ACK_CLOSEGRIPPER", 1)
            MoveGripper(2, 100, 100, 0, 30000, 1, 0, 0, 0, 0)
        
            -- Poll tot beweging klaar is (max 5 seconden)
            local done = 0
            for i = 1, 50 do
                local err, d = GetGripperMotionDone(2)
                if d == 1 then
                    done = 1
                    break
                end
                WaitMs(100)
            end
        
            if done == 1 then
                gripper_open = false
                SocketSend(0, "GRIPPER:CLOSED:CONFIRMED", 1)
            else
                SocketSend(0, "GRIPPER:CLOSED:TIMEOUT", 1)
            end
                end
                    
        end
    
        sleep_ms(2000)
end