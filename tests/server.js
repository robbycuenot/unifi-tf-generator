const express = require('express');
const https = require('https');
const path = require('path');
const fs = require('fs');
const app = express();

// Define the files and their endpoints
const files = [
  { type: 'accounts.json', endpoint: 'proxy/network/v2/api/site/default/radius/users' },
  { type: 'ap_groups.json', endpoint: 'proxy/network/v2/api/site/default/apgroups' },
  { type: 'devices.json', endpoint: 'proxy/network/v2/api/site/default/device' },
  { type: 'dynamic_dns.json', endpoint: 'proxy/network/api/s/default/rest/dynamicdns' },
  { type: 'firewall_groups.json', endpoint: 'proxy/network/api/s/default/rest/firewallgroup' },
  { type: 'firewall_rules.json', endpoint: 'proxy/network/api/s/default/rest/firewallrule' },
  { type: 'networks.json', endpoint: 'proxy/network/v2/api/site/default/lan/enriched-configuration' },
  { type: 'port_forward.json', endpoint: 'proxy/network/api/s/default/rest/portforward' },
  { type: 'port_profiles.json', endpoint: 'proxy/network/api/s/default/rest/portconf' },
  { type: 'radius_profiles.json', endpoint: 'proxy/network/api/s/default/rest/radiusprofile' },
  { type: 'settings.json', endpoint: 'proxy/network/api/s/default/get/setting' },
  { type: 'sites.json', endpoint: 'proxy/network/v2/api/info' },
  { type: 'static_routes.json', endpoint: 'proxy/network/api/s/default/rest/routing' },
  { type: 'user_groups.json', endpoint: 'proxy/network/api/s/default/rest/usergroup' },
  { type: 'users.json', endpoint: 'proxy/network/api/s/default/list/user' },
  { type: 'wlans.json', endpoint: 'proxy/network/api/s/default/rest/wlanconf' },
];

// Serve each file at its endpoint
files.forEach(file => {
  app.get(`/${file.endpoint}`, (req, res) => {
    res.sendFile(path.join(__dirname, 'json/raw', file.type));
  });
});

// HTTPS server options
const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};

// Create an HTTPS service identical to the HTTP service
https.createServer(options, app).listen(8080, () => {
  console.log('Mock API server running on HTTPS port 8080');
});