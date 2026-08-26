#!/usr/bin/env bash
# Smoke E2E vía Auth/REST API contra Supabase local + seed 006.
# Complementa la matriz manual de docs/access-model-e2e-validation.md.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

API="${SUPABASE_URL:-http://127.0.0.1:54321}"
ANON="${SUPABASE_ANON_KEY:-}"
if [[ -z "$ANON" ]]; then
  ANON="$(supabase status -o env 2>/dev/null | sed -n 's/^ANON_KEY="\(.*\)"/\1/p')"
fi
PASS="${E2E_PASSWORD:-ComunexaE2E!1}"

python3 - "$API" "$ANON" "$PASS" <<'PY'
import json, sys, urllib.request, urllib.error

API, ANON, PASS = sys.argv[1:4]

def req(method, path, body=None, token=None):
    headers = {"apikey": ANON, "Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body).encode()
    request = urllib.request.Request(API + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request) as resp:
            raw = resp.read().decode() or "null"
            return resp.status, json.loads(raw)
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode() or "null"
        try:
            payload = json.loads(raw)
        except json.JSONDecodeError:
            payload = raw
        return exc.code, payload

def login(email, password):
    return req(
        "POST",
        "/auth/v1/token?grant_type=password",
        {"email": email, "password": password},
    )

results = []

code, data = login("e2e-single@comunexa.local", "wrong")
results.append(("invalid_login", code >= 400 and "access_token" not in data, f"status={code}"))

cases = [
    ("e2e-single@comunexa.local", 1, "Torres del Parque"),
    ("e2e-multi@comunexa.local", 4, None),
    ("e2e-noaccess@comunexa.local", 0, None),
]
for email, expected, prop in cases:
    code, data = login(email, PASS)
    ok_login = code == 200 and isinstance(data, dict) and "access_token" in data
    name = ((data.get("user") or {}).get("user_metadata") or {}).get("full_name") if ok_login else None
    mems, props = [], []
    if ok_login:
        _, mems = req(
            "GET",
            "/rest/v1/property_memberships?select=id,role,property_id&status=eq.active",
            token=data["access_token"],
        )
        if not isinstance(mems, list):
            mems = []
        for membership in mems:
            _, rows = req(
                "GET",
                f"/rest/v1/properties?select=name&id=eq.{membership['property_id']}",
                token=data["access_token"],
            )
            props.append(rows[0]["name"] if isinstance(rows, list) and rows else None)
    results.append((f"login:{email}", ok_login, f"status={code} name={name}"))
    results.append(
        (
            f"memberships:{email}",
            len(mems) == expected and (prop is None or prop in props),
            f"count={len(mems)} props={props}",
        )
    )
    results.append((f"full_name:{email}", bool(name), repr(name)))

code, data = req("POST", "/auth/v1/recover", {"email": "e2e-single@comunexa.local"})
results.append(("password_recover", code in (200, 201), f"status={code}"))

code, data = login("e2e-single@comunexa.local", PASS)
token = data["access_token"]
code2, user = req("GET", "/auth/v1/user", token=token)
results.append(("session_user", code2 == 200 and user.get("email") == "e2e-single@comunexa.local", f"status={code2}"))
code3, _ = req("POST", "/auth/v1/logout", token=token)
results.append(("logout", code3 in (200, 204), f"status={code3}"))

all_ok = True
for name, ok, detail in results:
    print(("PASS" if ok else "FAIL"), name, "-", detail)
    all_ok = all_ok and ok
print("OVERALL", "PASS" if all_ok else "FAIL")
sys.exit(0 if all_ok else 1)
PY
