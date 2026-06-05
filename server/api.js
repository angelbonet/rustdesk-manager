const axios = require('axios');

async function get(url, headers = {}) {
    try {
        const resp = await axios.get(url, {
            headers,
            timeout: 10000
        });
        return resp.data;
    } catch (e) {
        console.error('API GET error:', e.message);
        return null;
    }
}

async function post(url, data, headers = {}) {
    try {
        const resp = await axios.post(url, data, {
            headers,
            timeout: 10000
        });
        return resp.data;
    } catch (e) {
        console.error('API POST error:', e.message);
        return null;
    }
}

module.exports = { get, post };
