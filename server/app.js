const express = require('express');
const bodyParser = require('body-parser');
const mqtt = require('mqtt');
const app = express();
const sqlite3 = require('sqlite3').verbose();


const db = new sqlite3.Database(process.env.FEEDER_DATA || ':memory:');

db.serialize(function() {

    // Telemetry table contains the successive states of the device
    db.run(`CREATE TABLE IF NOT EXISTS telemetry (
        id INTEGER PRIMARY KEY,
        epoch INTEGER,
        heap INTEGER,
        cron TEXT
    )`);

    // Events table contains individual events
    db.run(`CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY,
        epoch INTEGER,
        type TEXT
    )`);
});

const MQTT_HOST = process.env.MQTT_HOST;
const MQTT_PORT = process.env.MQTT_PORT;

// TODO: MOVE MQTT SERVER TO SEPARATE CONFIG FILE!
const client = mqtt.connect(`mqtt://${MQTT_HOST}:${MQTT_PORT}`, {
    username: process.env.MQTT_USER,
    password: process.env.MQTT_PASSWORD
});
 
client.on('connect', function () {
    console.log('Successfully connected to mqtt');
    client.subscribe('/gaston/telemetry');
});

client.on('error', (err) => {
    console.log('Error:');
    console.log(err);
});
 
client.on('message', function (topic, message) {
    // message is Buffer
    const parsed = JSON.parse(message.toString());

    if (parsed.event) {
        // The message is an event report
        const stmt = db.prepare("INSERT INTO events VALUES (NULL, ?, ?)");
        stmt.run(parsed.epoch, parsed.event);
        stmt.finalize();
    } else {
        // The message is a telemetry report
        const stmt = db.prepare("INSERT INTO telemetry VALUES (NULL, ?, ?, ?)");
        stmt.run(parsed.epoch, parsed.heap, parsed.cron);
        stmt.finalize();
    }
});

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.post('/api/feed', (req, res) => {
    console.log(req.body);
    client.publish('/gaston/commands', '{"dispense":true}', (e) => {
        if (e) console.error(e);
        else {
            res.redirect('/');
        }
    });
});
app.post('/api/schedule', (req, res) => {
    const schedule = req.body.schedule;
    client.publish('/gaston/commands', `{"schedule":"${schedule}"}`, (e) => {
        if (e) console.error(e);
        else {
            res.redirect('/');
        }
    });
});

app.get('/api/telemetry', (req, res) => {
    const pgSize = 30;
    const p = req.query['page'] || 0;
    db.all('SELECT * FROM telemetry ORDER BY id DESC LIMIT ? OFFSET ?', [pgSize, p * pgSize], (err, rows) => {
        res.send(rows);
    });
});

app.get('/api/events', (req, res) => {
    const pgSize = 30;
    const p = req.query['page'] || 0;
    const type = req.query['type'] || '%';
    db.all('SELECT * FROM events WHERE type LIKE ? ORDER BY id DESC LIMIT ? OFFSET ?', [type, pgSize, p * pgSize], (err, rows) => {
        res.send(rows);
    });
});

app.use(express.static('public'));

app.listen(3000, () => console.log('Example app listening on port 3000!'));

