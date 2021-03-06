
-- What we found so far:
-- enduser_setup handles all wifi stuff by itself
-- servos are controlled by pulse length
-- with nodemcu's pwm module this means create a pwm with freq 50Hz and vary duty between 30 and 125

dofile('env.lua')

local servoPosTake = 75
local servoPosRelease = 100
local servoPosNeutral = 120

CONFIG_FILE="config.json"
SERVO_GPIO=6

config = {}
config["cron"] = "0 10 * * *"
config["doses"] = 1

pwm.setup(SERVO_GPIO, 50, servoPosNeutral)
pwm.start(SERVO_GPIO)

feedcron = nil

enduser_setup.start()

sendStatus = function()
    if client ~= nil then
        client:publish("/gaston/status", '{"config":' .. sjson.encode(config) .. '}', 0, 0, function(client) print("sent") end)
    end
end

sendEvent = function(type)
    if client ~= nil then
        sec = rtctime.get()
        client:publish("/gaston/events", '{"event":"' .. type .. '","epoch":' .. sec .. '}', 0, 0, function(client) print("sent") end)
    end
end

updatecron = function()
    if feedcron == nil then
        local tryInit = pcall(function()
                feedcron = cron.schedule(config.cron, function()
                    dispense()
                    sendStatus()
                end)
            end)
        if tryInit == false then
            print('config is corrupt! Erasing config...')
            file.remove(CONFIG_FILE)
            node.restart()
        end
    else
        feedcron:unschedule()
        feedcron:schedule(config.cron)
    end
end

setConfig = function(cfg)
    if cfg.cron ~= nil then
        config.cron = cfg.cron
    end
    if cfg.doses ~= nil then
        config.doses = cfg.doses
    end
end

loadConfig = function()
    if file.open(CONFIG_FILE, "r") then
        local data = file.read()
        file.close()
        setConfig(sjson.decode(data))
    end
end

writeConfig = function()
    if file.open(CONFIG_FILE, "w+") then
        file.write(sjson.encode(config))
        file.close()
    end
end

dispenseOne = function(cb)
    pwm.setduty(SERVO_GPIO, servoPosTake)
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
        pwm.setduty(SERVO_GPIO, servoPosRelease)
        tmr.create():alarm(1000, tmr.ALARM_SINGLE, function()
            cb()
        end)
    end)
end

dispense = function()
    print('Dispensing...')
    sendEvent('dispense')
    
    local remainingDoses = config.doses
    dispenseRec = function()
        dispenseOne(function()
            remainingDoses = remainingDoses - 1
            if remainingDoses > 0 then
                dispenseRec()
            else
                pwm.setduty(SERVO_GPIO, servoPosNeutral)
                print('Done dispensing.')
            end
        end)
    end
    dispenseRec()
end

connectTries = 0
connect = function()
    connectTries = connectTries + 1
    m:connect(MQTT_HOST, MQTT_PORT, MQTT_SECURE, function(cl)
        print("mqtt connected")
        client = cl
        client:subscribe("/gaston/commands", 0, function(client) print("subscribe success") end)
        sendEvent('connect')
        sendStatus()
    end,
    function(client, reason)
        print('Mqtt failed, reason: ' .. reason)
        tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, connect)
    end)
end

initMqtt = function()
    m = mqtt.Client("gaston0", 60, MQTT_USER, MQTT_PASSWORD)

    -- setup Last Will and Testament
    -- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
    -- to topic "/lwt" if client don't send keepalive packet
    m:lwt("/lwt", "offline", 0, 0)

    m:on("offline", function(client)
        print ("offline")
        tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, connect)
    end)

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

        if decoded.config ~= nil then
            setConfig(decoded.config)
            writeConfig()
            updatecron()
        end

        sendStatus()
    end)
end

main = function()
    local hasTime = false
    local hasWifi = false

    loadConfig()
    initMqtt()

    local onComponentInit = function()
        if hasTime == true and hasWifi == true then
            updatecron()
            connect()
        end
    end

    -- Init clock with network time
    sntp.sync(nil, function()
        print('Success getting time')
        hasTime = true
        onComponentInit()
    end, function(e)
        print('Error getting time: ' .. e)
    end, true)
    
    -- Init wifi listener
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
        T.netmask.."\n\tGateway IP: "..T.gateway)
        hasWifi = true
        onComponentInit()
    end)
end

main()
