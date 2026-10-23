import os
import time
from flask import Flask, request, redirect, render_template_string
import psycopg

app = Flask(__name__)

TENANT_NAME = os.getenv("TENANT_NAME", "tenant-unknown")
DB_HOST = os.getenv("DB_HOST", "postgres")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "appuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")


def get_connection():
    return psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5,
    )


def init_db():
    for attempt in range(30):
        try:
            with get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("""
                        CREATE TABLE IF NOT EXISTS messages (
                            id SERIAL PRIMARY KEY,
                            content TEXT NOT NULL,
                            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                        )
                    """)
            print(f"Database ready for {TENANT_NAME}", flush=True)
            return
        except psycopg.OperationalError as exc:
            print(f"Waiting for PostgreSQL ({attempt + 1}/30)", flush=True)
            time.sleep(2)

    raise RuntimeError("PostgreSQL is not reachable")


PAGE = """
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Démo multitenant - {{ tenant }}</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 760px; margin: 40px auto;
           padding: 0 18px; background: #f4f6f8; color: #172033; }
    .card { background: white; padding: 24px; border-radius: 12px;
            box-shadow: 0 3px 14px #0001; margin-bottom: 18px; }
    input { width: 70%; padding: 11px; }
    button { padding: 11px 16px; cursor: pointer; }
    li { margin: 12px 0; overflow-wrap: anywhere; }
    .tenant { color: #176b45; font-weight: bold; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Application multitenant</h1>
    <p>Tenant actif : <span class="tenant">{{ tenant }}</span></p>
    <p>Base de données : <strong>{{ database }}</strong></p>
    <form action="/add" method="post">
      <input name="content" maxlength="500" required
             placeholder="Écris un message pour ce tenant">
      <button type="submit">Enregistrer</button>
    </form>
  </div>
  <div class="card">
    <h2>Messages enregistrés</h2>
    {% if messages %}
      <ul>
      {% for message in messages %}
        <li>{{ message[1] }} <small>— {{ message[2] }}</small></li>
      {% endfor %}
      </ul>
    {% else %}
      <p>Aucun message pour le moment. Ajoute le premier !</p>
    {% endif %}
  </div>
</body>
</html>
"""


@app.get("/")
def index():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id, content, to_char(created_at, 'YYYY-MM-DD HH24:MI:SS')
                FROM messages ORDER BY id DESC LIMIT 50
            """)
            messages = cur.fetchall()

    return render_template_string(
        PAGE, tenant=TENANT_NAME, database=DB_NAME, messages=messages
    )


@app.post("/add")
def add_message():
    content = request.form.get("content", "").strip()
    if content:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO messages (content) VALUES (%s)",
                    (content[:500],),
                )
    return redirect("/")


@app.get("/healthz")
def health():
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
        return {"status": "ok", "tenant": TENANT_NAME}, 200
    except psycopg.Error:
        return {"status": "database unavailable"}, 503


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=8080)
