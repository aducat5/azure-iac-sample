const args = process.argv.slice(2);

const url = process.argv[2];

const flags = args.filter(a => a.startsWith("-") || a.startsWith("--"));

if(!url) {
    console.error('Missing url')
    process.exit(1);
}

if(!url.startsWith('https')) {
    console.error('Must start with https')
    process.exit(1);
}

if(flags.includes('-d')) {
    removeUrl(url).then(() => {
        console.log('success');
        process.exit(0);
    }).catch(e => {
        console.log('error', e.message);
        process.exit(1);
    });
}
else if(flags.includes('-a')) {
    addNewUrl(url).then(() => {
        console.log('success');
        process.exit(0);
    }).catch(e => {
        console.log('error', e.message);
        process.exit(1);
    });
}
else {
    console.error('no flag was given');
    process.exit(1);
}

async function addNewUrl(url) {
    const token = await getToken();
  
    const client = await getClient(token);
  
    const { callbacks } = client;
  
    const list = [...callbacks, url];
  
    const body = { callbacks: list, allowed_logout_urls: list, web_origins: list };
  
    const addNewUrlRes = await fetch(
      "https://<appname>.eu.auth0.com/api/v2/clients/<clienttoken>",
      {
        method: "PATCH",
        headers: {
          authorization: `Bearer ${token}`,
          "content-type": "application/json",
        },
        body: JSON.stringify(body),
      }
    );
  
    const addNewUrlJson = await addNewUrlRes.json();
  
    return addNewUrlJson;
  }

  async function removeUrl() {
    const token = await getToken();
  
    const client = await getClient(token);
  
    const { callbacks } = client;
  
    const list = callbacks.filter(c => c !== url);
  
    const body = { callbacks: list, allowed_logout_urls: list, web_origins: list };
  
    const addNewUrlRes = await fetch(
      "https://<appname>.eu.auth0.com/api/v2/clients/<clienttoken>",
      {
        method: "PATCH",
        headers: {
          authorization: `Bearer ${token}`,
          "content-type": "application/json",
        },
        body: JSON.stringify(body),
      }
    );
  
    const addNewUrlJson = await addNewUrlRes.json();
  
    return addNewUrlJson;
  }
  
  async function getToken() {
    const tokenRes = await fetch("https://<appname>.eu.auth0.com/oauth/token", {
      body: `{"client_id":"<clientid>","client_secret":"<clientsecret>","audience":"https://<appname>.eu.auth0.com/api/v2/","grant_type":"client_credentials"}`,
      headers: {
        "content-type": "application/json",
      },
      method: "POST",
    });
  
    const tokenJson = await tokenRes.json();
  
    const { access_token } = tokenJson;
  
    return access_token;
  }
  
  async function getClient(token) {
    const clientRes = await fetch(
      "https://<appname>.eu.auth0.com/api/v2/clients/<appname>",
      {
        headers: {
          authorization: `Bearer ${token}`,
        },
      }
    );
  
    const clientJson = await clientRes.json();
  
    return clientJson;
  }