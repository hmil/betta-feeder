
-- What we found so far:
-- enduser_setup handles all wifi stuff by itself
-- servos are controlled by pulse length
-- with nodemcu's pwm module this means create a pwm with freq 50Hz and vary duty between 30 and 125

dofile('env.lua')

local servoPosTake = 75
local servoPosRelease = 100
local servoPosNeutral = 120
local cronline = "0 10 * * *" -- Default cronline is every day at 10 O'clock

enduser_setup.start()

sntp.sync(nil, function()
    print('Success getting time')
end, function(e)
    print('Error getting time: ' .. e)
end, true)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
    T.netmask.."\n\tGateway IP: "..T.gateway)
end)

dispense = function()
    print('Dispensing')
    sec = rtctime.get()
    if client ~= nil then
        client:publish("/gaston/telemetry", '{"event":"dispense","epoch":' .. sec .. '}', 0, 0, function(client) print("sent") end)
    end
    pwm.setduty(6, servoPosTake)
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
        pwm.setduty(6, servoPosRelease)
        tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
            pwm.setduty(6, servoPosNeutral)
        end)
    end)
end

telemetry = function()
    print('Sending telemetry')
    if client ~= nil then
        client:publish("/gaston/telemetry"
                , '{"heap":' .. node.heap() .. ', "cron":"' .. cronline .. '", "epoch":' .. rtctime.get() .. '}'
                , 0, 0
                , function(client) print("telemetry sent") end)
    end
end


feedcron = cron.schedule(cronline, dispense)
telemetrycron = cron.schedule("* * * * *", telemetry)


writecron = function(line)
    if file.open("schedule.cron", "w") then
        file.write(line)
        file.close()
    end
end

initcron = function()
    if not file.exists("schedule.cron") then
        writecron(cronline)
    end

    if file.open("schedule.cron") then
        local line = file.read()
        file.close()
        cronline = line
        feedcron:unschedule()
        feedcron:schedule(cronline)
    end
end

pwm.setup(6, 50, servoPosNeutral)
pwm.start(6)

m = mqtt.Client("clientid", 60, MQTT_USER, MQTT_PASSWORD)

-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "offline", 0, 0)

m:on("connect", function(client) print ("connected") end)
m:on("offline", function(client) print ("offline") end)

-- on publish message receive event
m:on("message", function(client, topic, data) 
    print(topic .. ":") 
    if data ~= nil then
        print(data)
    end

    decoded = sjson.decode(data)

    if decoded.dispense == true then
        dispense()
    end

    if decoded.schedule ~= nil and decoded.schedule ~= sjson.NULL then
        print('Scheduling')
        feedcron:unschedule()
        if decoded.schedule ~= "clear" then
            cronline = decoded.schedule
            writecron(cronline)   
            print('cron written')         
            feedcron:schedule(cronline)
            telemetry()
        end
    end
end)

connectTries = 0
connect = function()
    connectTries = connectTries + 1
    m:connect(MQTT_HOST, MQTT_PORT, MQTT_SECURE, function(cl)
        print("mqtt connected")
        sec = rtctime.get()
        client = cl
        client:subscribe("/gaston/commands", 0, function(client) print("subscribe success") end)
        client:publish("/gaston/telemetry", '{"event":"boot","epoch":' .. sec .. '}', 0, 0, function(client) print("sent") end)
    end,
    function(client, reason)
        print("failed reason: " .. reason)
        if connectTries < 5 then
            connect()
        end
    end)
end

connect()
initcron()