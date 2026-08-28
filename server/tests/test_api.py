"""The relay's API and admin panel.

Run with:

    python3 -m unittest discover -s server/tests

Everything runs against a real SQLite file in a temporary directory and the real
Flask app, so the SQL and the routing are exercised rather than mocked. scrypt
is deliberately weakened here: the production parameters take tens of
milliseconds each and this suite signs in dozens of times.
"""

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from server import admin, auth, chat, db          # noqa: E402
from server.app import create_app                 # noqa: E402

auth.SCRYPT = {"n": 2, "r": 8, "p": 1}


class RelayTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)

        path = str(Path(self.directory.name) / "eos.db")
        self.app = create_app({
            "DB_PATH": path,
            "TESTING": True,
            "SECRET_KEY": "test",
            "ALLOWED_ORIGINS": ["https://example.github.io"],
        })
        self.client = self.app.test_client()

        with self.app.app_context():
            self.alice = self.make_user("alice", "alpha-pass", is_admin=True)
            self.bob = self.make_user("bob", "bravo-pass")
            self.carol = self.make_user("carol", "charlie-pass")
            self.direct = self.make_direct(self.alice, self.bob)
            self.group = self.make_group("Book club", [self.alice, self.bob])

    # -- fixtures ---------------------------------------------------------

    def make_user(self, username, password, is_admin=False):
        return admin.create_user(username, username.title(), password, is_admin)

    def make_direct(self, a, b):
        conversation = db.execute(
            "INSERT INTO conversations (kind, name, created_by, created_at) "
            "VALUES ('direct', NULL, ?, ?)", (a, db.now()))
        for user in (a, b):
            db.execute("INSERT INTO members (conversation_id, user_id, joined_at) "
                       "VALUES (?, ?, ?)", (conversation, user, db.now()))
        return conversation

    def make_group(self, name, users):
        conversation = db.execute(
            "INSERT INTO conversations (kind, name, created_by, created_at) "
            "VALUES ('group', ?, ?, ?)", (name, users[0], db.now()))
        for user in users:
            db.execute("INSERT INTO members (conversation_id, user_id, joined_at) "
                       "VALUES (?, ?, ?)", (conversation, user, db.now()))
        return conversation

    # -- helpers ----------------------------------------------------------

    def login(self, username, password):
        response = self.client.post("/api/login",
                                    json={"username": username, "password": password})
        self.assertEqual(response.status_code, 200, response.get_json())
        return response.get_json()["token"]

    def get(self, path, token):
        return self.client.get(path, headers={"Authorization": f"Bearer {token}"})

    def post(self, path, token, payload):
        return self.client.post(path, json=payload,
                                headers={"Authorization": f"Bearer {token}"})


class TestSignIn(RelayTest):
    def test_good_credentials_return_a_token_and_the_user(self):
        response = self.client.post("/api/login",
                                    json={"username": "alice", "password": "alpha-pass"})
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertTrue(data["token"])
        self.assertEqual(data["user"]["username"], "alice")
        self.assertTrue(data["user"]["isAdmin"])

    def test_username_is_not_case_sensitive(self):
        self.assertEqual(
            self.client.post("/api/login",
                             json={"username": "ALICE", "password": "alpha-pass"}).status_code,
            200)

    def test_a_wrong_password_and_a_missing_account_look_the_same(self):
        wrong = self.client.post("/api/login",
                                 json={"username": "alice", "password": "nope"})
        missing = self.client.post("/api/login",
                                   json={"username": "nobody", "password": "nope"})
        self.assertEqual(wrong.status_code, 401)
        self.assertEqual(missing.status_code, 401)
        self.assertEqual(wrong.get_json(), missing.get_json())

    def test_no_token_is_401(self):
        self.assertEqual(self.client.get("/api/me").status_code, 401)

    def test_a_made_up_token_is_401(self):
        self.assertEqual(self.get("/api/me", "not-a-real-token").status_code, 401)

    def test_logout_stops_the_token_working(self):
        token = self.login("alice", "alpha-pass")
        self.assertEqual(self.get("/api/me", token).status_code, 200)
        self.post("/api/logout", token, {})
        self.assertEqual(self.get("/api/me", token).status_code, 401)

    def test_the_stored_token_is_not_the_token(self):
        token = self.login("alice", "alpha-pass")
        with self.app.app_context():
            rows = db.query("SELECT hash FROM tokens")
        self.assertTrue(rows)
        for row in rows:
            self.assertNotIn(token.encode(), bytes(row["hash"]))

    def test_a_disabled_account_cannot_sign_in_or_keep_a_token(self):
        token = self.login("bob", "bravo-pass")
        with self.app.app_context():
            db.execute("UPDATE users SET disabled = 1 WHERE id = ?", (self.bob,))
        self.assertEqual(self.get("/api/me", token).status_code, 401)
        self.assertEqual(
            self.client.post("/api/login",
                             json={"username": "bob", "password": "bravo-pass"}).status_code,
            401)


class TestMessages(RelayTest):
    def test_a_message_comes_back_to_both_members(self):
        alice = self.login("alice", "alpha-pass")
        bob = self.login("bob", "bravo-pass")

        sent = self.post("/api/messages", alice, {
            "conversationId": self.direct, "body": "hello", "clientId": "c1"})
        self.assertEqual(sent.status_code, 200, sent.get_json())

        for token in (alice, bob):
            data = self.get("/api/messages?since=0", token).get_json()
            bodies = [m["body"] for m in data["messages"]]
            self.assertIn("hello", bodies)

    def test_the_cursor_only_advances_over_messages_it_returned(self):
        alice = self.login("alice", "alpha-pass")
        self.post("/api/messages", alice,
                  {"conversationId": self.direct, "body": "one", "clientId": "c1"})

        first = self.get("/api/messages?since=0", alice).get_json()
        self.assertEqual(len(first["messages"]), 1)
        self.assertEqual(first["cursor"], first["messages"][0]["id"])

        again = self.get(f"/api/messages?since={first['cursor']}", alice).get_json()
        self.assertEqual(again["messages"], [])
        self.assertEqual(again["cursor"], first["cursor"])

    def test_a_cursor_does_not_skip_past_someone_elses_conversation(self):
        """carol's cursor must not be dragged forward by messages she cannot see."""
        alice = self.login("alice", "alpha-pass")
        carol = self.login("carol", "charlie-pass")
        carol_group = None
        with self.app.app_context():
            carol_group = self.make_group("Carol and Alice", [self.alice, self.carol])

        # A message carol cannot see, then one she can.
        self.post("/api/messages", alice,
                  {"conversationId": self.direct, "body": "private", "clientId": "p1"})
        self.post("/api/messages", alice,
                  {"conversationId": carol_group, "body": "shared", "clientId": "s1"})

        data = self.get("/api/messages?since=0", carol).get_json()
        self.assertEqual([m["body"] for m in data["messages"]], ["shared"])

    def test_a_non_member_cannot_read_or_write(self):
        carol = self.login("carol", "charlie-pass")

        refused = self.post("/api/messages", carol, {
            "conversationId": self.direct, "body": "sneak", "clientId": "x1"})
        self.assertEqual(refused.status_code, 404)

        alice = self.login("alice", "alpha-pass")
        self.post("/api/messages", alice,
                  {"conversationId": self.direct, "body": "secret", "clientId": "s2"})
        data = self.get("/api/messages?since=0", carol).get_json()
        self.assertEqual(data["messages"], [])

    def test_an_empty_or_overlong_message_is_refused(self):
        alice = self.login("alice", "alpha-pass")
        for body in ("", "   ", "x" * (chat.BODY_LIMIT + 1)):
            response = self.post("/api/messages", alice, {
                "conversationId": self.direct, "body": body, "clientId": f"e{len(body)}"})
            self.assertEqual(response.status_code, 400, body[:20])

    def test_sending_the_same_client_id_twice_stores_one_message(self):
        alice = self.login("alice", "alpha-pass")
        payload = {"conversationId": self.direct, "body": "once", "clientId": "dup"}

        first = self.post("/api/messages", alice, payload).get_json()
        second = self.post("/api/messages", alice, payload).get_json()

        self.assertTrue(first["created"])
        self.assertFalse(second["created"])
        self.assertEqual(first["message"]["id"], second["message"]["id"])

        data = self.get("/api/messages?since=0", alice).get_json()
        self.assertEqual(len(data["messages"]), 1)


class TestBatch(RelayTest):
    """The calculator's outbox, handed over by the sync page."""

    def payload(self, *bodies, from_calculator=True):
        return {
            "fromCalculator": from_calculator,
            "messages": [
                {"conversationId": self.direct, "body": body, "clientId": f"calc-{body}"}
                for body in bodies
            ],
        }

    def test_a_batch_is_stored_and_marks_the_account_as_a_calculator(self):
        alice = self.login("alice", "alpha-pass")
        response = self.post("/api/messages/batch", alice, self.payload("a", "b"))
        self.assertEqual(response.status_code, 200, response.get_json())
        self.assertEqual(response.get_json()["created"], 2)

        me = self.get("/api/me", alice).get_json()
        self.assertTrue(me["user"]["hasCalculator"])
        self.assertTrue(me["user"]["lastCalcSync"])

    def test_replaying_a_batch_creates_nothing_new(self):
        """The case this exists for: the sync died before the acknowledgement."""
        alice = self.login("alice", "alpha-pass")
        self.post("/api/messages/batch", alice, self.payload("a", "b"))
        again = self.post("/api/messages/batch", alice, self.payload("a", "b"))

        self.assertEqual(again.get_json()["created"], 0)
        data = self.get("/api/messages?since=0", alice).get_json()
        self.assertEqual(len(data["messages"]), 2)

    def test_a_partly_replayed_batch_stores_only_what_is_new(self):
        alice = self.login("alice", "alpha-pass")
        self.post("/api/messages/batch", alice, self.payload("a"))
        mixed = self.post("/api/messages/batch", alice, self.payload("a", "b"))
        self.assertEqual(mixed.get_json()["created"], 1)

    def test_a_batch_for_someone_elses_conversation_is_refused(self):
        carol = self.login("carol", "charlie-pass")
        response = self.post("/api/messages/batch", carol, self.payload("x"))
        self.assertEqual(response.status_code, 404)

    def test_an_oversized_batch_is_refused(self):
        alice = self.login("alice", "alpha-pass")
        response = self.post("/api/messages/batch", alice, {
            "messages": [{"conversationId": self.direct, "body": "x", "clientId": f"n{i}"}
                         for i in range(chat.BATCH_LIMIT + 1)]})
        self.assertEqual(response.status_code, 400)


class TestRoster(RelayTest):
    def test_the_roster_shows_who_reads_on_a_calculator(self):
        alice = self.login("alice", "alpha-pass")
        bob = self.login("bob", "bravo-pass")
        self.post("/api/calc/sync", bob, {})

        roster = self.get("/api/roster", alice).get_json()["roster"]
        entries = {entry["username"]: entry for entry in roster}

        self.assertTrue(entries["bob"]["hasCalculator"])
        self.assertTrue(entries["bob"]["lastCalcSync"])
        self.assertFalse(entries["alice"]["hasCalculator"])

    def test_a_direct_conversation_is_named_after_the_other_person(self):
        alice = self.login("alice", "alpha-pass")
        bob = self.login("bob", "bravo-pass")

        for token, expect in ((alice, "Bob"), (bob, "Alice")):
            data = self.get("/api/me", token).get_json()
            direct = [c for c in data["conversations"] if c["kind"] == "direct"][0]
            self.assertEqual(direct["name"], expect)

    def test_me_lists_only_the_conversations_you_are_in(self):
        carol = self.login("carol", "charlie-pass")
        self.assertEqual(self.get("/api/me", carol).get_json()["conversations"], [])


class TestCors(RelayTest):
    def test_a_known_origin_is_allowed_and_the_preflight_answered(self):
        response = self.client.options("/api/messages", headers={
            "Origin": "https://example.github.io",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "Authorization",
        })
        self.assertEqual(response.status_code, 204)
        self.assertEqual(response.headers.get("Access-Control-Allow-Origin"),
                         "https://example.github.io")
        self.assertIn("Authorization", response.headers.get("Access-Control-Allow-Headers", ""))
        self.assertEqual(response.headers.get("Vary"), "Origin")

    def test_an_unknown_origin_gets_no_allow_header(self):
        response = self.client.options("/api/messages",
                                       headers={"Origin": "https://evil.example"})
        self.assertIsNone(response.headers.get("Access-Control-Allow-Origin"))


class TestAdmin(RelayTest):
    def sign_in(self):
        return self.client.post("/admin/login",
                                data={"username": "alice", "password": "alpha-pass"},
                                follow_redirects=True)

    def test_the_panel_needs_an_admin(self):
        response = self.client.get("/admin/users")
        self.assertEqual(response.status_code, 302)

        self.client.post("/admin/login",
                         data={"username": "bob", "password": "bravo-pass"})
        self.assertEqual(self.client.get("/admin/users").status_code, 302)

    def test_an_admin_sees_everyone(self):
        self.sign_in()
        body = self.client.get("/admin/users").get_data(as_text=True)
        for name in ("alice", "bob", "carol"):
            self.assertIn(name, body)

    def test_adding_a_user_lets_them_sign_in(self):
        self.sign_in()
        self.client.post("/admin/users/new",
                         data={"username": "dave", "password": "delta-pass"})
        self.assertEqual(
            self.client.post("/api/login",
                             json={"username": "dave", "password": "delta-pass"}).status_code,
            200)

    def test_a_username_is_validated(self):
        self.sign_in()
        self.client.post("/admin/users/new",
                         data={"username": "bad name!", "password": "whatever1"})
        with self.app.app_context():
            self.assertIsNone(
                db.query("SELECT 1 FROM users WHERE username LIKE 'bad%'", one=True))

    def test_resetting_a_password_signs_the_old_sessions_out(self):
        token = self.login("bob", "bravo-pass")
        self.sign_in()
        self.client.post(f"/admin/users/{self.bob}/password", data={"password": "new-pass1"})

        self.assertEqual(self.get("/api/me", token).status_code, 401)
        self.assertEqual(
            self.client.post("/api/login",
                             json={"username": "bob", "password": "new-pass1"}).status_code,
            200)

    def test_disabling_a_user_signs_them_out(self):
        token = self.login("bob", "bravo-pass")
        self.sign_in()
        self.client.post(f"/admin/users/{self.bob}/disable")
        self.assertEqual(self.get("/api/me", token).status_code, 401)

    def test_an_admin_cannot_lock_themselves_out(self):
        self.sign_in()
        self.client.post(f"/admin/users/{self.alice}/disable")
        self.client.post(f"/admin/users/{self.alice}/admin")
        self.client.post(f"/admin/users/{self.alice}/delete")

        with self.app.app_context():
            row = db.query("SELECT * FROM users WHERE id = ?", (self.alice,), one=True)
        self.assertIsNotNone(row)
        self.assertTrue(row["is_admin"])
        self.assertFalse(row["disabled"])

    def test_creating_a_group_lets_its_members_talk(self):
        self.sign_in()
        self.client.post("/admin/groups/new",
                         data={"name": "Study", "members": [str(self.bob), str(self.carol)]})

        with self.app.app_context():
            group = db.query("SELECT id FROM conversations WHERE name = 'Study'",
                             one=True)["id"]

        bob = self.login("bob", "bravo-pass")
        self.assertEqual(
            self.post("/api/messages", bob,
                      {"conversationId": group, "body": "hi", "clientId": "g1"}).status_code,
            200)

        alice = self.login("alice", "alpha-pass")
        self.assertEqual(
            self.post("/api/messages", alice,
                      {"conversationId": group, "body": "no", "clientId": "g2"}).status_code,
            404)

    def test_removing_a_member_removes_their_access(self):
        self.sign_in()
        bob = self.login("bob", "bravo-pass")
        self.assertEqual(
            self.post("/api/messages", bob,
                      {"conversationId": self.group, "body": "in", "clientId": "m1"}).status_code,
            200)

        self.client.post(f"/admin/groups/{self.group}/members",
                         data={"user_id": str(self.bob), "remove": "1"})
        self.assertEqual(
            self.post("/api/messages", bob,
                      {"conversationId": self.group, "body": "out", "clientId": "m2"}).status_code,
            404)

    def test_deleting_a_user_keeps_the_conversation_readable(self):
        alice = self.login("alice", "alpha-pass")
        bob = self.login("bob", "bravo-pass")
        self.post("/api/messages", bob,
                  {"conversationId": self.direct, "body": "still here", "clientId": "k1"})

        self.sign_in()
        self.client.post(f"/admin/users/{self.bob}/delete")

        data = self.get("/api/messages?since=0", alice).get_json()
        self.assertEqual([m["body"] for m in data["messages"]], ["still here"])
        self.assertIsNone(data["messages"][0]["userId"])

    def test_only_one_direct_conversation_per_pair(self):
        self.sign_in()
        self.client.post("/admin/direct", data={"a": str(self.alice), "b": str(self.bob)})
        with self.app.app_context():
            count = db.query(
                "SELECT COUNT(*) AS n FROM conversations WHERE kind = 'direct'",
                one=True)["n"]
        self.assertEqual(count, 1)


class TestBootstrap(unittest.TestCase):
    """An empty relay has to be able to make its first administrator."""

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.app = create_app({
            "DB_PATH": str(Path(self.directory.name) / "eos.db"),
            "TESTING": True,
            "SECRET_KEY": "test",
        })
        self.client = self.app.test_client()

    def test_the_first_run_offers_to_create_an_admin(self):
        self.assertIn("First run", self.client.get("/admin/login").get_data(as_text=True))

        self.client.post("/admin/bootstrap",
                         data={"username": "root", "password": "rootpass1"})

        # ...and stops offering once there is one.
        self.assertNotIn("First run", self.client.get("/admin/login").get_data(as_text=True))

        signed_in = self.client.post("/admin/login",
                                     data={"username": "root", "password": "rootpass1"},
                                     follow_redirects=True)
        self.assertIn("People", signed_in.get_data(as_text=True))

    def test_a_short_password_is_refused(self):
        self.client.post("/admin/bootstrap", data={"username": "root", "password": "short"})
        with self.app.app_context():
            self.assertEqual(db.query("SELECT COUNT(*) AS n FROM users", one=True)["n"], 0)


if __name__ == "__main__":
    unittest.main()
