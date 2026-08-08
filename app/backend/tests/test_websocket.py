"""
Phase 6 Batch 1 & 2: WebSocket Dashboard + Caregiver Notification Tests

Tests authenticated WebSocket connections, ownership enforcement,
real-time event broadcasting, and full regression of existing REST APIs.
"""
import json
import time
import warnings
from datetime import datetime, timezone, timedelta

warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", category=UserWarning)

from fastapi.testclient import TestClient

# Use existing Firebase initialization
from app.firebase.database import db  # triggers firebase init via import chain
from app.main import app
from app.models.firestore_schema import Collections
from app.websocket.manager import ConnectionManager
from app.mqtt.mqtt_service import MQTTService
from app.websocket.events import broadcast_medication, broadcast_heartbeat
from app.services.medicine_service import MedicineService
from app.schemas.medicine import MedicineUpdate

client = TestClient(app, raise_server_exceptions=False)

TEST_UID = "ws_test_user_alpha"
TEST_UID_B = "ws_test_user_beta"
TEST_TOKEN = f"test-token-{TEST_UID}"
TEST_TOKEN_B = f"test-token-{TEST_UID_B}"
HEADERS = {"Authorization": f"Bearer {TEST_TOKEN}"}
HEADERS_B = {"Authorization": f"Bearer {TEST_TOKEN_B}"}

# Maximum messages to drain from a WS before giving up (prevents infinite hang)
WS_DRAIN_LIMIT = 50

created_ids = {"users": [], "robots": [], "medicines": [], "emergencies": [], "caregivers": [], "notifications": []}

# ── Explicit collection name map (fails loudly on mismatch) ──
_COLLECTION_MAP = {}
for _key in created_ids:
    _enum_name = _key.upper()
    if not hasattr(Collections, _enum_name):
        raise RuntimeError(f"Collections enum has no member '{_enum_name}' — cleanup will be incomplete, aborting")
    _COLLECTION_MAP[_key] = getattr(Collections, _enum_name)


def cleanup():
    """Remove all test data from Firestore."""
    # 1. Delete tracked documents by ID
    for col_key, ids in created_ids.items():
        col_enum = _COLLECTION_MAP[col_key]
        for doc_id in ids:
            try:
                db.collection(col_enum.value).document(doc_id).delete()
            except Exception:
                pass

    # 2. Sweep by field matches across ALL collections
    sweep_fields = [
        ("user_id", TEST_UID),
        ("user_id", TEST_UID_B),
        ("patient_id", TEST_UID),
        ("patient_id", TEST_UID_B),
        ("recipient_id", TEST_UID),
        ("recipient_id", TEST_UID_B),
        ("assigned_patient_id", TEST_UID),
        ("assigned_patient_id", TEST_UID_B),
    ]
    for col_enum in Collections:
        for field, value in sweep_fields:
            try:
                docs = db.collection(col_enum.value).where(field, "==", value).stream()
                for doc in docs:
                    db.collection(col_enum.value).document(doc.id).delete()
            except Exception:
                pass


def drain_ws_until_pong(ws, limit=WS_DRAIN_LIMIT):
    """Read messages from WS until a pong is received or limit is reached.
    Returns the list of non-pong events collected. Never hangs."""
    events = []
    for _ in range(limit):
        raw = ws.receive_text()
        msg = json.loads(raw)
        if msg.get("type") == "pong":
            return events
        events.append(msg)
    # If we hit the limit without a pong, return what we have
    return events


results = []


def record(name, passed, detail=""):
    status = "PASS" if passed else "FAIL"
    results.append((name, status, detail))
    print(f"  {'✅' if passed else '❌'} {name}: {status}" + (f" — {detail}" if detail else ""))


# ═══════════════════════════════════════════════════════════
# Setup (cleanup-guaranteed)
# ═══════════════════════════════════════════════════════════
print("\n🧹 Cleaning up previous test data...")
cleanup()

robot_id_a = None
robot_id_b = None
setup_failed = False

try:
    print("\n🔧 Creating test fixtures...")
    # Create user A
    r = client.post("/api/v1/users", json={"full_name": "WS Test User A", "email": "ws_a@test.com", "phone_number": "1111111111"}, headers=HEADERS)
    if r.status_code == 200:
        created_ids["users"].append(r.json().get("id", TEST_UID))

    # Create user B
    r = client.post("/api/v1/users", json={"full_name": "WS Test User B", "email": "ws_b@test.com", "phone_number": "2222222222"}, headers=HEADERS_B)
    if r.status_code == 200:
        created_ids["users"].append(r.json().get("id", TEST_UID_B))

    # Create robot for user A
    r = client.post("/api/v1/robots", json={"robot_id": "ws-robot-01", "device_name": "WS Robot", "user_id": TEST_UID, "status": "ACTIVE", "wifi_connected": True, "battery_percentage": 90, "firmware_version": "1.0.0"}, headers=HEADERS)
    if r.status_code != 200:
        raise RuntimeError(f"Robot A creation failed: {r.status_code} {r.text}")
    robot_id_a = r.json()["id"]
    created_ids["robots"].append(robot_id_a)

    # Create robot for user B
    r = client.post("/api/v1/robots", json={"robot_id": "ws-robot-02", "device_name": "WS Robot B", "user_id": TEST_UID_B, "status": "ACTIVE", "wifi_connected": True, "battery_percentage": 85, "firmware_version": "1.0.0"}, headers=HEADERS_B)
    if r.status_code != 200:
        raise RuntimeError(f"Robot B creation failed: {r.status_code} {r.text}")
    robot_id_b = r.json()["id"]
    created_ids["robots"].append(robot_id_b)

except Exception as e:
    print(f"\n❌ SETUP FAILED: {e}")
    setup_failed = True

if setup_failed:
    print("\n🧹 Cleaning up after setup failure...")
    cleanup()
    print("\n❌ Cannot continue — setup did not complete.")
    exit(1)

# ═══════════════════════════════════════════════════════════
# All tests run inside try/finally to guarantee cleanup
# ═══════════════════════════════════════════════════════════
try:
    # ═══════════════════════════════════════════════════════════
    print("\n" + "=" * 60)
    print("  PHASE 6 BATCH 1 — WEBSOCKET DASHBOARD TESTS")
    print("=" * 60)

    # ─── Test 1: Authenticated WebSocket connection ───────────
    print("\n📡 Test 1: Authenticated WebSocket Connection")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            resp = json.loads(ws.receive_text())
            record("WS auth connection", resp.get("type") == "auth_success" and resp.get("user_id") == TEST_UID)
    except Exception as e:
        record("WS auth connection", False, str(e))

    # ─── Test 2: Missing authentication → rejected ───────────
    print("\n🚫 Test 2: Missing Authentication Rejected")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": ""}))
            resp = json.loads(ws.receive_text())
            record("WS missing auth rejected", resp.get("type") == "error")
    except Exception as e:
        # Connection closed = also valid rejection
        record("WS missing auth rejected", True, "Connection closed")

    # ─── Test 3: Invalid token → rejected ────────────────────
    print("\n🚫 Test 3: Invalid Token Rejected")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": "invalid-firebase-token-xyz"}))
            resp = json.loads(ws.receive_text())
            record("WS invalid token rejected", resp.get("type") == "error")
    except Exception as e:
        record("WS invalid token rejected", True, "Connection closed")

    # ─── Test 4: Bad auth message format → rejected ──────────
    print("\n🚫 Test 4: Bad Auth Message Format Rejected")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text("not-json")
            resp = json.loads(ws.receive_text())
            record("WS bad format rejected", resp.get("type") == "error")
    except Exception as e:
        record("WS bad format rejected", True, "Connection closed")

    # ─── Test 5: No auth type in message → rejected ──────────
    print("\n🚫 Test 5: Wrong Message Type Rejected")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "subscribe", "token": TEST_TOKEN}))
            resp = json.loads(ws.receive_text())
            record("WS wrong msg type rejected", resp.get("type") == "error")
    except Exception as e:
        record("WS wrong msg type rejected", True, "Connection closed")

    # ─── Test 6: Ping/Pong keepalive ─────────────────────────
    print("\n🏓 Test 6: Ping/Pong Keepalive")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            auth_resp = json.loads(ws.receive_text())
            assert auth_resp["type"] == "auth_success"

            ws.send_text(json.dumps({"type": "ping"}))
            pong = json.loads(ws.receive_text())
            record("WS ping/pong", pong.get("type") == "pong")
    except Exception as e:
        record("WS ping/pong", False, str(e))

    # ─── Test 7: ConnectionManager singleton ─────────────────
    print("\n🔌 Test 7: ConnectionManager Singleton")
    m1 = ConnectionManager()
    m2 = ConnectionManager()
    record("ConnectionManager singleton", m1 is m2)

    # ─── Test 8: Telemetry → WebSocket event ─────────────────
    print("\n📊 Test 8: Telemetry → WebSocket Event")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            auth_resp = json.loads(ws.receive_text())
            assert auth_resp["type"] == "auth_success"

            # Trigger telemetry via MQTT service (simulated)
            MQTTService.handle_telemetry(
                "vitalcode/robots/ws-robot-01/telemetry",
                {"robot_id": "ws-robot-01", "battery_percentage": 75, "wifi_connected": True}
            )

            ws.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws)

            telemetry_events = [e for e in events_received if e.get("type") == "telemetry"]
            has_telemetry = len(telemetry_events) > 0 and telemetry_events[0].get("robot_id") == robot_id_a
            record("Telemetry → WS event", has_telemetry, f"Got {len(events_received)} events: {events_received}")
    except Exception as e:
        record("Telemetry → WS event", False, str(e))

    # ─── Test 9: Location/Waypoint → WebSocket event ─────────
    print("\n📍 Test 9: Location/Waypoint → WebSocket Event")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            auth_resp = json.loads(ws.receive_text())
            assert auth_resp["type"] == "auth_success"

            MQTTService.handle_telemetry(
                "vitalcode/robots/ws-robot-01/telemetry",
                {"robot_id": "ws-robot-01", "latitude": 37.7749, "longitude": -122.4194, "latest_waypoint": "Kitchen", "waypoint_status": "EN_ROUTE"}
            )

            ws.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws)

            location_events = [e for e in events_received if e.get("type") == "location"]
            has_location = len(location_events) > 0 and location_events[0].get("data", {}).get("latitude") == 37.7749
            record("Location → WS event", has_location, f"Got {len(location_events)} location events")
    except Exception as e:
        record("Location → WS event", False, str(e))

    # ─── Test 10: Emergency → WebSocket alert ────────────────
    print("\n🚨 Test 10: Emergency → WebSocket Alert")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            auth_resp = json.loads(ws.receive_text())
            assert auth_resp["type"] == "auth_success"

            # Create emergency via REST
            r = client.post("/api/v1/emergencies", json={
                "robot_id": robot_id_a,
                "patient_id": TEST_UID,
                "alert_type": "FALL_DETECTED",
                "severity": "HIGH",
                "sensor_source": "TEST",
                "acknowledged": False,
                "location": "Living Room",
            }, headers=HEADERS)
            assert r.status_code == 200, f"Emergency create failed: {r.text}"
            created_ids["emergencies"].append(r.json()["id"])

            ws.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws)

            emergency_events = [e for e in events_received if e.get("type") == "emergency"]
            has_emergency = len(emergency_events) > 0 and emergency_events[0].get("data", {}).get("alert_type") == "FALL_DETECTED"
            record("Emergency → WS alert", has_emergency, f"Got {len(emergency_events)} emergency events")
    except Exception as e:
        record("Emergency → WS alert", False, str(e))

    # ─── Test 11: User B does NOT receive User A's events ────
    print("\n🔒 Test 11: Ownership Isolation (User B ≠ User A events)")
    try:
        with client.websocket_connect("/ws/dashboard") as ws_b:
            ws_b.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN_B}))
            auth_resp = json.loads(ws_b.receive_text())
            assert auth_resp["type"] == "auth_success"

            # Trigger user A's telemetry
            MQTTService.handle_telemetry(
                "vitalcode/robots/ws-robot-01/telemetry",
                {"robot_id": "ws-robot-01", "battery_percentage": 60}
            )

            ws_b.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws_b)

            # Filter for telemetry events targeting user A's robot
            leaked = [e for e in events_received if e.get("type") == "telemetry" and e.get("robot_id") == robot_id_a]
            record("Ownership isolation", len(leaked) == 0, f"Leaked events: {len(leaked)}")
    except Exception as e:
        record("Ownership isolation", False, str(e))

    # ─── Test 12: Medication Status → WebSocket event ────────
    print("\n💊 Test 12: Medication Status → WebSocket Event")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            auth_resp = json.loads(ws.receive_text())
            assert auth_resp["type"] == "auth_success"

            # Broadcast medication event directly (simulating scheduler)
            broadcast_medication(TEST_UID, {
                "medicine_id": "test-med-001",
                "status": "REMINDED",
                "medicine_name": "Test Med",
            })

            ws.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws)

            med_events = [e for e in events_received if e.get("type") == "medication"]
            has_med = len(med_events) > 0 and med_events[0].get("data", {}).get("status") == "REMINDED"
            record("Medication → WS event", has_med, f"Got {len(med_events)} medication events")
    except Exception as e:
        record("Medication → WS event", False, str(e))

    # ─── Test 13: Heartbeat Status → WebSocket event ─────────
    print("\n💓 Test 13: Heartbeat Status → WebSocket Event")
    try:
        with client.websocket_connect("/ws/dashboard") as ws:
            ws.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            auth_resp = json.loads(ws.receive_text())
            assert auth_resp["type"] == "auth_success"

            broadcast_heartbeat(TEST_UID, robot_id_a, {
                "status": "ONLINE",
                "last_heartbeat_at": datetime.now(timezone.utc).isoformat(),
            })

            ws.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws)

            hb_events = [e for e in events_received if e.get("type") == "heartbeat"]
            has_hb = len(hb_events) > 0 and hb_events[0].get("data", {}).get("status") == "ONLINE"
            record("Heartbeat → WS event", has_hb, f"Got {len(hb_events)} heartbeat events")
    except Exception as e:
        record("Heartbeat → WS event", False, str(e))

    # ─── Test 14: Disconnect/Reconnect Stability ─────────────
    print("\n🔄 Test 14: Disconnect/Reconnect Stability")
    try:
        # Connect
        with client.websocket_connect("/ws/dashboard") as ws1:
            ws1.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            r1 = json.loads(ws1.receive_text())
            assert r1["type"] == "auth_success"

        # Reconnect
        with client.websocket_connect("/ws/dashboard") as ws2:
            ws2.send_text(json.dumps({"type": "auth", "token": TEST_TOKEN}))
            r2 = json.loads(ws2.receive_text())
            assert r2["type"] == "auth_success"

            ws2.send_text(json.dumps({"type": "ping"}))
            pong = json.loads(ws2.receive_text())
            record("Disconnect/reconnect", pong.get("type") == "pong")
    except Exception as e:
        record("Disconnect/reconnect", False, str(e))


    # ═══════════════════════════════════════════════════════════
    print("\n" + "=" * 60)
    print("  PHASE 6 BATCH 2 — CAREGIVER REAL-TIME NOTIFICATIONS")
    print("=" * 60)

    # Create primary caregiver 1 for patient A
    cg_id_1 = None
    r = client.post("/api/v1/caregivers", json={
        "full_name": "Caregiver Alpha",
        "email": "cg_a@test.com",
        "phone": "5555555555",
        "relationship": "Spouse",
        "assigned_patient_id": TEST_UID,
        "is_primary": True
    }, headers=HEADERS)
    if r.status_code == 200:
        cg_id_1 = r.json()["id"]
        created_ids["caregivers"].append(cg_id_1)
    print(f"Created caregiver 1: {cg_id_1}")

    # Create primary caregiver 2 for patient B
    cg_id_2 = None
    r = client.post("/api/v1/caregivers", json={
        "full_name": "Caregiver Beta",
        "email": "cg_b@test.com",
        "phone": "6666666666",
        "relationship": "Sibling",
        "assigned_patient_id": TEST_UID_B,
        "is_primary": True
    }, headers=HEADERS_B)
    if r.status_code == 200:
        cg_id_2 = r.json()["id"]
        created_ids["caregivers"].append(cg_id_2)
    print(f"Created caregiver 2: {cg_id_2}")

    CG_TOKEN_1 = f"test-token-{cg_id_1}"
    CG_TOKEN_2 = f"test-token-{cg_id_2}"

    # ─── Test 15: Emergency → Caregiver WebSocket event ─────
    print("\n🚨 Test 15: Emergency → Caregiver Notification WebSocket Event")
    try:
        with client.websocket_connect("/ws/dashboard") as ws_cg:
            ws_cg.send_text(json.dumps({"type": "auth", "token": CG_TOKEN_1}))
            auth_resp = json.loads(ws_cg.receive_text())
            assert auth_resp["type"] == "auth_success"

            # Trigger emergency for patient A
            r = client.post("/api/v1/emergencies", json={
                "robot_id": robot_id_a,
                "patient_id": TEST_UID,
                "alert_type": "PANIC_BUTTON",
                "severity": "HIGH",
                "sensor_source": "TEST",
                "acknowledged": False,
                "location": "Kitchen",
            }, headers=HEADERS)
            assert r.status_code == 200
            created_ids["emergencies"].append(r.json()["id"])

            ws_cg.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws_cg)

            notif_events = [e for e in events_received if e.get("type") == "notification"]
            has_notif = len(notif_events) > 0 and notif_events[0].get("data", {}).get("notification_type") == "EMERGENCY"

            # Verify document exists in Firestore
            docs = db.collection(Collections.NOTIFICATIONS.value).where("recipient_id", "==", cg_id_1).stream()
            fired_notifs = [d.id for d in docs]
            created_ids["notifications"].extend(fired_notifs)

            record("Emergency → Caregiver WS + Firestore", has_notif and len(fired_notifs) > 0, f"WS notification: {has_notif}, DB: {len(fired_notifs)}")
    except Exception as e:
        record("Emergency → Caregiver WS + Firestore", False, str(e))

    # ─── Test 16: Missed medication → Caregiver WebSocket event ───
    print("\n💊 Test 16: Missed Medication → Caregiver Notification WebSocket Event")
    try:
        with client.websocket_connect("/ws/dashboard") as ws_cg:
            ws_cg.send_text(json.dumps({"type": "auth", "token": CG_TOKEN_1}))
            auth_resp = json.loads(ws_cg.receive_text())
            assert auth_resp["type"] == "auth_success"

            # Step 1: Create medicine via REST with valid MedicineCreate fields only
            due_time = (datetime.now(timezone.utc) - timedelta(minutes=5)).isoformat()
            r = client.post("/api/v1/medicines", json={
                "medicine_name": "Missed Caregiver Med",
                "dosage": "50mg",
                "patient_id": TEST_UID,
                "scheduled_time": due_time,
                "requires_confirmation": True,
            }, headers=HEADERS)
            assert r.status_code == 200, f"Medicine create failed: {r.status_code} {r.text}"
            med_id = r.json()["id"]
            created_ids["medicines"].append(med_id)

            # Step 2: Use PUT to set server-managed state to trigger missed-medication path
            # The scheduler marks REMINDED→MISSED when retry_count >= 3 and last_sent_at is >30s ago
            r = client.put(f"/api/v1/medicines/{med_id}", json={
                "status": "REMINDED",
                "retry_count": 3,
                "last_sent_at": (datetime.now(timezone.utc) - timedelta(seconds=40)).isoformat()
            }, headers=HEADERS)
            assert r.status_code == 200, f"Medicine update failed: {r.status_code} {r.text}"

            # Step 3: Trigger scheduler
            MedicineService().process_scheduled_medicines()

            # Check websocket
            ws_cg.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws_cg)

            notif_events = [e for e in events_received if e.get("type") == "notification"]
            has_notif = len(notif_events) > 0 and notif_events[0].get("data", {}).get("notification_type") == "MEDICINE"

            # Verify Firestore
            docs = db.collection(Collections.NOTIFICATIONS.value).where("recipient_id", "==", cg_id_1).where("notification_type", "==", "MEDICINE").stream()
            fired_notifs = [d.id for d in docs]
            created_ids["notifications"].extend(fired_notifs)

            record("Missed medication → Caregiver WS + Firestore", has_notif and len(fired_notifs) > 0, f"WS: {has_notif}, DB: {len(fired_notifs)}")
    except Exception as e:
        record("Missed medication → Caregiver WS + Firestore", False, str(e))

    # ─── Test 17: Caregiver disconnected → Firestore notification still created ───
    print("\n🔌 Test 17: Caregiver Disconnected (No WebSocket Error)")
    try:
        # No websocket connection is open for caregiver 1
        # Trigger emergency for patient A
        r = client.post("/api/v1/emergencies", json={
            "robot_id": robot_id_a,
            "patient_id": TEST_UID,
            "alert_type": "PANIC_BUTTON",
            "severity": "CRITICAL",
            "sensor_source": "TEST",
            "acknowledged": False,
            "location": "Bedroom",
        }, headers=HEADERS)
        assert r.status_code == 200
        created_ids["emergencies"].append(r.json()["id"])

        # Verify Firestore notification is still created
        docs = db.collection(Collections.NOTIFICATIONS.value).where("recipient_id", "==", cg_id_1).where("priority", "==", "CRITICAL").stream()
        fired_notifs = [d.id for d in docs]
        created_ids["notifications"].extend(fired_notifs)

        record("Disconnected caregiver → DB notification still created", len(fired_notifs) > 0, f"Created {len(fired_notifs)} critical alerts")
    except Exception as e:
        record("Disconnected caregiver → DB notification still created", False, str(e))

    # ─── Test 18: Wrong caregiver → receives nothing ────────
    print("\n🔒 Test 18: Wrong Caregiver Receives Nothing")
    try:
        with client.websocket_connect("/ws/dashboard") as ws_cg2:
            ws_cg2.send_text(json.dumps({"type": "auth", "token": CG_TOKEN_2}))
            auth_resp = json.loads(ws_cg2.receive_text())
            assert auth_resp["type"] == "auth_success"

            # Trigger emergency for patient A (which caregiver 2 is NOT assigned to)
            r = client.post("/api/v1/emergencies", json={
                "robot_id": robot_id_a,
                "patient_id": TEST_UID,
                "alert_type": "FALL_DETECTED",
                "severity": "HIGH",
                "sensor_source": "TEST",
                "acknowledged": False,
                "location": "Garden",
            }, headers=HEADERS)
            assert r.status_code == 200
            created_ids["emergencies"].append(r.json()["id"])

            ws_cg2.send_text(json.dumps({"type": "ping"}))
            events_received = drain_ws_until_pong(ws_cg2)

            leaked_notifs = [e for e in events_received if e.get("type") == "notification"]
            record("Wrong caregiver isolation", len(leaked_notifs) == 0, f"Leaked: {len(leaked_notifs)}")
    except Exception as e:
        record("Wrong caregiver isolation", False, str(e))


    # ═══════════════════════════════════════════════════════════
    print("\n" + "=" * 60)
    print("  FULL REGRESSION — EXISTING REST APIS")
    print("=" * 60)

    # ─── Regression: Health check ─────────────────────────────
    print("\n🩺 Regression: Health Check")
    r = client.get("/health")
    record("GET /health", r.status_code == 200 and r.json().get("status") == "ok")

    # ─── Regression: User CRUD ────────────────────────────────
    print("\n👤 Regression: User CRUD")
    r = client.get(f"/api/v1/users/{TEST_UID}", headers=HEADERS)
    record("GET /users/{id}", r.status_code == 200 and r.json().get("full_name") == "WS Test User A")

    # ─── Regression: Robot CRUD ───────────────────────────────
    print("\n🤖 Regression: Robot CRUD")
    r = client.get(f"/api/v1/robots/{robot_id_a}", headers=HEADERS)
    record("GET /robots/{id}", r.status_code == 200 and r.json().get("device_name") == "WS Robot")

    r = client.get(f"/api/v1/robots/{robot_id_a}/location", headers=HEADERS)
    record("GET /robots/{id}/location", r.status_code == 200)

    # ─── Regression: Robot Auth ───────────────────────────────
    print("\n🔐 Regression: Robot Ownership")
    r = client.get(f"/api/v1/robots/{robot_id_a}", headers=HEADERS_B)
    record("Robot cross-user blocked", r.status_code == 403)

    # ─── Regression: Medicine CRUD ────────────────────────────
    print("\n💊 Regression: Medicine CRUD")
    r = client.post("/api/v1/medicines", json={
        "medicine_name": "WS Test Med",
        "dosage": "10mg",
        "patient_id": TEST_UID,
        "scheduled_time": datetime.now(timezone.utc).isoformat(),
        "requires_confirmation": False,
    }, headers=HEADERS)
    record("POST /medicines", r.status_code == 200)
    if r.status_code == 200:
        med_id = r.json()["id"]
        created_ids["medicines"].append(med_id)
        r2 = client.get(f"/api/v1/medicines/{med_id}", headers=HEADERS)
        record("GET /medicines/{id}", r2.status_code == 200)

    # ─── Regression: Emergency CRUD ───────────────────────────
    print("\n🚨 Regression: Emergency CRUD")
    r = client.get(f"/api/v1/emergencies/{created_ids['emergencies'][0]}", headers=HEADERS) if created_ids["emergencies"] else None
    if r:
        record("GET /emergencies/{id}", r.status_code == 200)
    else:
        record("GET /emergencies/{id}", False, "No emergency ID available")

    # ─── Regression: No Auth → 401/403 ───────────────────────
    print("\n🔒 Regression: Unauthenticated Requests")
    r = client.get("/api/v1/users/foo")
    record("No auth → 401/403", r.status_code in (401, 403))

finally:
    # ═══════════════════════════════════════════════════════════
    # Cleanup (guaranteed)
    # ═══════════════════════════════════════════════════════════
    print("\n🧹 Cleaning up test data...")
    cleanup()

    # ── Verify zero remaining documents ──────────────────────
    print("\n🔍 Verifying zero remaining test documents...")
    remaining_count = 0
    sweep_fields = [
        ("user_id", TEST_UID),
        ("user_id", TEST_UID_B),
        ("patient_id", TEST_UID),
        ("patient_id", TEST_UID_B),
        ("recipient_id", TEST_UID),
        ("recipient_id", TEST_UID_B),
        ("assigned_patient_id", TEST_UID),
        ("assigned_patient_id", TEST_UID_B),
    ]
    for col_enum in Collections:
        for field, value in sweep_fields:
            try:
                docs = list(db.collection(col_enum.value).where(field, "==", value).stream())
                if docs:
                    remaining_count += len(docs)
                    print(f"  ⚠️  {col_enum.value}: {len(docs)} stale doc(s) matched {field}=={value}")
                    # Force delete stragglers
                    for doc in docs:
                        db.collection(col_enum.value).document(doc.id).delete()
            except Exception:
                pass

    if remaining_count == 0:
        print("  ✅ Firestore cleanup verified: ZERO test documents remain")
    else:
        print(f"  ⚠️  Cleaned {remaining_count} straggler(s) in verification pass")

    # ─── Summary ─────────────────────────────────────────────
    print("\n" + "=" * 60)
    print("  RESULTS SUMMARY")
    print("=" * 60)
    total = len(results)
    passed = sum(1 for _, s, _ in results if s == "PASS")
    failed = sum(1 for _, s, _ in results if s == "FAIL")
    print(f"\n  Total: {total}  |  ✅ Passed: {passed}  |  ❌ Failed: {failed}\n")
    for name, status, detail in results:
        print(f"  {'✅' if status == 'PASS' else '❌'} {name}: {status}" + (f" — {detail}" if detail else ""))

    print(f"\n{'=' * 60}")
    if failed == 0:
        print("  ALL TESTS PASSED ✅")
    else:
        print(f"  {failed} TEST(S) FAILED ❌")
    print(f"{'=' * 60}\n")
