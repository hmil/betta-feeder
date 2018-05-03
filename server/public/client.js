
function request(path, data) {

    return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();

        const method = (data == null) ? 'GET' : 'POST';

        xhr.responseType = 'json';
        xhr.open(method, path, true); 
        xhr.onreadystatechange = function() {
            if(xhr.readyState == XMLHttpRequest.DONE && xhr.status == 200) {
                resolve(xhr.response);
            }
        }
    
        if (method === 'POST') {
            xhr.setRequestHeader("Content-type", "application/json");
            xhr.send(JSON.stringify(data));
        } else {
            xhr.send();
        }
    });
}

function feed() {
    console.log('Feeding');
    request('/api/feed', {});
}

function boot() {

    const cronLine = document.getElementById('input-schedule');
    const statusLine = document.getElementById('status-line');

    refreshTelemetry();
    refreshEvents();

    async function refreshTelemetry() {
        const telemetry = await request('/api/telemetry');

        console.log(telemetry);
        if (telemetry.length > 0) {
            cronLine.value = telemetry[0].cron;
        }
    }

    async function refreshEvents() {
        const events = await request('/api/events?type=dispense');

        console.log(events);
        if (events.length > 0) {
            const lastTime = new Date(events[0].epoch * 1000);
            statusLine.innerText = `Last time gaston ate: ${lastTime.toLocaleDateString()} at ${lastTime.toLocaleTimeString()}`;
        } else {
            statusLine.innerText = 'Online, no status info';
        }
    }
}