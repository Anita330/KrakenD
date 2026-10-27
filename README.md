# Authentication

This sandbox uses Keycloak as the identity provider and KrakenD JWT validation on every public `/api/*` endpoint.

## Start the Stack

```bash
docker compose up --build
```

Keycloak runs at:

```text
http://localhost:8082
```

Default local admin credentials:

```text
username: admin
password: admin
```

You can override them with:

```bash
KEYCLOAK_ADMIN_USERNAME=my-admin KEYCLOAK_ADMIN_PASSWORD=my-password docker compose up --build
```

## Test User

```text
realm: krakend-sandbox
client: krakend-sandbox-client
username: sandbox-user
password: sandbox-password
realm role: api-user
```

## Get an Access Token

```bash
TOKEN=$(
  curl -s \
    -X POST "http://localhost:8082/realms/krakend-sandbox/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password" \
    -d "client_id=krakend-sandbox-client" \
    -d "username=sandbox-user" \
    -d "password=sandbox-password" \
  | jq -r .access_token
)
```

PowerShell:

```powershell
$tokenResponse = Invoke-RestMethod `
  -Method Post `
  -Uri "http://localhost:8082/realms/krakend-sandbox/protocol/openid-connect/token" `
  -ContentType "application/x-www-form-urlencoded" `
  -Body @{
    grant_type = "password"
    client_id = "krakend-sandbox-client"
    username = "sandbox-user"
    password = "sandbox-password"
  }

$TOKEN = $tokenResponse.access_token
```

## Call KrakenD

Without a token, KrakenD should reject the request:

```bash
curl -i "http://localhost:8080/api/users"
```

Expected result:

```text
HTTP/1.1 401 Unauthorized
```

With a valid token, KrakenD should proxy the request:

```bash
curl -i "http://localhost:8080/api/users" \
  -H "Authorization: Bearer $TOKEN"
```

PowerShell:

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/users" `
  -Headers @{ Authorization = "Bearer $TOKEN" }
```

Expected result: a successful response with the backend JSON payload.


To check the rate limit
```
for i in {1..10}; do
  echo "Request $i"
  curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/api/users
done
```