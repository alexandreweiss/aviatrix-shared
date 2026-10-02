"""
Rise Up MCP Server — Users & Groups
Exposes Rise Up REST API (v3) as MCP tools.

Note: The Rise Up API does not expose forum/community discussion endpoints.
      Community boards are controlled via the `community` boolean on Groups
      and the `forumcategory` boolean on Courses.
"""

from __future__ import annotations

import base64
import os
import time
from typing import Any, Optional

import httpx
from dotenv import load_dotenv
from mcp.server.fastmcp import FastMCP

load_dotenv()

PUBLIC_KEY: str = os.environ.get("RISEUP_PUBLIC_KEY", "")
PRIVATE_KEY: str = os.environ.get("RISEUP_PRIVATE_KEY", "")
API_BASE: str = os.environ.get("RISEUP_API_BASE", "https://api.riseup.ai").rstrip("/")

# ---------------------------------------------------------------------------
# Token cache
# ---------------------------------------------------------------------------
_token: str | None = None
_token_expiry: float = 0.0


def _get_token() -> str:
    global _token, _token_expiry
    if _token and time.time() < _token_expiry:
        return _token
    credentials = base64.b64encode(f"{PUBLIC_KEY}:{PRIVATE_KEY}".encode()).decode()
    resp = httpx.post(
        f"{API_BASE}/oauth/token",
        headers={
            "Authorization": f"Basic {credentials}",
            "Content-Type": "application/x-www-form-urlencoded",
        },
        data={"grant_type": "client_credentials"},
        timeout=15,
    )
    resp.raise_for_status()
    data = resp.json()
    _token = data["access_token"]
    _token_expiry = time.time() + data.get("expires_in", 3600) - 30
    return _token


def _headers() -> dict[str, str]:
    return {"Authorization": f"Bearer {_get_token()}"}


def _get(path: str, params: dict | None = None) -> Any:
    resp = httpx.get(f"{API_BASE}/v3{path}", headers=_headers(), params=params, timeout=30)
    resp.raise_for_status()
    return resp.json() if resp.content else {}


def _post(path: str, body: Any = None) -> Any:
    resp = httpx.post(f"{API_BASE}/v3{path}", headers=_headers(), json=body, timeout=30)
    resp.raise_for_status()
    return resp.json() if resp.content else {}


def _put(path: str, body: Any = None) -> Any:
    resp = httpx.put(f"{API_BASE}/v3{path}", headers=_headers(), json=body, timeout=30)
    resp.raise_for_status()
    return resp.json() if resp.content else {}


def _delete(path: str) -> Any:
    resp = httpx.delete(f"{API_BASE}/v3{path}", headers=_headers(), timeout=30)
    resp.raise_for_status()
    return {"deleted": True} if not resp.content else resp.json()


# ---------------------------------------------------------------------------
# MCP server
# ---------------------------------------------------------------------------
mcp = FastMCP("riseup")


# ===========================================================================
# USERS
# ===========================================================================


@mcp.tool()
def list_users(
    username: Optional[str] = None,
    firstname: Optional[str] = None,
    lastname: Optional[str] = None,
    email: Optional[str] = None,
    state: Optional[str] = None,
    idgroup: Optional[int] = None,
    rhid: Optional[str] = None,
    limit: Optional[int] = None,
    range: Optional[str] = None,
) -> Any:
    """List all users. Filter by username, firstname, lastname, email, state
    ('active','inactive','suspend'), idgroup, or rhid. Use limit (max 500)
    and range (e.g. '0-49') for pagination."""
    params: dict = {}
    for k, v in {
        "username": username,
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "state": state,
        "idgroup": idgroup,
        "rhid": rhid,
        "limit": limit,
        "range": range,
    }.items():
        if v is not None:
            params[k] = v
    return _get("/users", params or None)


@mcp.tool()
def get_user(user_id: int) -> Any:
    """Fetch a single user by their numeric ID."""
    return _get(f"/users/{user_id}")


@mcp.tool()
def create_user(
    username: str,
    email: str,
    firstname: str,
    lastname: str,
    role: str = "user",
    type: str = "internal",
    language: Optional[str] = None,
    idpartner: Optional[int] = None,
    rhid: Optional[str] = None,
    timezone: Optional[str] = None,
    phonenumber: Optional[str] = None,
) -> Any:
    """Create a new user. role: 'admin','user','trainer','adminpartner',
    'sessioninstructor','communitymanager','learnerauthor'.
    type: 'public','internal','external'."""
    body: dict = {
        "username": username,
        "email": email,
        "firstname": firstname,
        "lastname": lastname,
        "role": role,
        "type": type,
    }
    for k, v in {
        "language": language,
        "idpartner": idpartner,
        "rhid": rhid,
        "timezone": timezone,
        "phonenumber": phonenumber,
    }.items():
        if v is not None:
            body[k] = v
    return _post("/users", body)


@mcp.tool()
def update_user(
    user_id: int,
    firstname: Optional[str] = None,
    lastname: Optional[str] = None,
    email: Optional[str] = None,
    role: Optional[str] = None,
    state: Optional[str] = None,
    language: Optional[str] = None,
    timezone: Optional[str] = None,
    phonenumber: Optional[str] = None,
    rhid: Optional[str] = None,
) -> Any:
    """Update an existing user. Only provided fields are changed."""
    body: dict = {}
    for k, v in {
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "role": role,
        "state": state,
        "language": language,
        "timezone": timezone,
        "phonenumber": phonenumber,
        "rhid": rhid,
    }.items():
        if v is not None:
            body[k] = v
    return _put(f"/users/{user_id}", body)


@mcp.tool()
def delete_user(user_id: int) -> Any:
    """Delete a user by their numeric ID."""
    return _delete(f"/users/{user_id}")


@mcp.tool()
def list_pending_users(
    username: Optional[str] = None,
    email: Optional[str] = None,
    firstname: Optional[str] = None,
    lastname: Optional[str] = None,
    idgroup: Optional[int] = None,
    limit: Optional[int] = None,
    range: Optional[str] = None,
) -> Any:
    """List users whose registration is pending approval."""
    params: dict = {}
    for k, v in {
        "username": username,
        "email": email,
        "firstname": firstname,
        "lastname": lastname,
        "idgroup": idgroup,
        "limit": limit,
        "range": range,
    }.items():
        if v is not None:
            params[k] = v
    return _get("/users/pendingUsers", params or None)


@mcp.tool()
def get_pending_user(user_id: int) -> Any:
    """Fetch a single pending user by their numeric ID."""
    return _get(f"/users/pendingUsers/{user_id}")


@mcp.tool()
def accept_pending_user(user_id: int) -> Any:
    """Accept a pending user registration, activating their account."""
    return _post(f"/users/pendingUsers/{user_id}/accept")


@mcp.tool()
def refuse_pending_user(user_id: int) -> Any:
    """Refuse a pending user registration, disabling and deleting their account."""
    resp = httpx.post(
        f"{API_BASE}/v3/users/pendingUsers/refuse/{user_id}",
        headers=_headers(),
        timeout=30,
    )
    resp.raise_for_status()
    return {"refused": True}


@mcp.tool()
def remind_inactive_user(user_id: int) -> Any:
    """Send a reminder email to an inactive user."""
    return _get(f"/users/remindInactive/{user_id}")


# ===========================================================================
# GROUPS
# Note: Groups include a `community` boolean that enables a forum/community
# board for the group on the Rise Up platform. This is the only API-level
# control over group community boards; forum posts themselves are not
# accessible via the API.
# ===========================================================================


@mcp.tool()
def list_groups(
    iduser: Optional[int] = None,
    admin: Optional[bool] = None,
    limit: Optional[int] = None,
    range: Optional[str] = None,
) -> Any:
    """List all groups. Filter by iduser (groups the user belongs to) or
    admin=true (groups where user is an admin). The `community` field in
    the response indicates whether a group has a community board enabled."""
    params: dict = {}
    for k, v in {
        "iduser": iduser,
        "admin": admin,
        "limit": limit,
        "range": range,
    }.items():
        if v is not None:
            params[k] = v
    return _get("/groups", params or None)


@mcp.tool()
def get_group(group_id: int) -> Any:
    """Fetch a single group by its numeric ID. The `community` field shows
    whether the group's community board is active."""
    return _get(f"/groups/{group_id}")


@mcp.tool()
def create_group(
    name: str,
    reference: Optional[str] = None,
    hidden: Optional[bool] = None,
    community: Optional[bool] = None,
    managercanmanagetrainings: Optional[str] = None,
    idpartner: Optional[int] = None,
) -> Any:
    """Create a new group. Set community=True to enable a community/forum
    board for this group on the Rise Up platform.
    managercanmanagetrainings: 'none','visible','every'."""
    body: dict = {"name": name}
    for k, v in {
        "reference": reference,
        "hidden": hidden,
        "community": community,
        "managercanmanagetrainings": managercanmanagetrainings,
        "idpartner": idpartner,
    }.items():
        if v is not None:
            body[k] = v
    return _post("/groups", body)


@mcp.tool()
def update_group(
    group_id: int,
    name: Optional[str] = None,
    reference: Optional[str] = None,
    hidden: Optional[bool] = None,
    community: Optional[bool] = None,
    managercanmanagetrainings: Optional[str] = None,
) -> Any:
    """Update an existing group. Set community=True/False to toggle the
    community board for the group."""
    body: dict = {}
    for k, v in {
        "name": name,
        "reference": reference,
        "hidden": hidden,
        "community": community,
        "managercanmanagetrainings": managercanmanagetrainings,
    }.items():
        if v is not None:
            body[k] = v
    return _put(f"/groups/{group_id}", body)


@mcp.tool()
def delete_group(group_id: int) -> Any:
    """Delete a group by its numeric ID."""
    return _delete(f"/groups/{group_id}")


@mcp.tool()
def subscribe_users_to_group(group_id: int, user_ids: list[int]) -> Any:
    """Add one or more users to a group. Provide a list of user IDs."""
    payload = [{"id": uid} for uid in user_ids]
    return _post(f"/groups/{group_id}/subscribe", payload)


@mcp.tool()
def unsubscribe_users_from_group(group_id: int, user_ids: list[int]) -> Any:
    """Remove one or more users from a group. No emails are sent.
    Provide a list of user IDs."""
    payload = [{"id": uid} for uid in user_ids]
    return _post(f"/groups/{group_id}/unsubscribe", payload)


@mcp.tool()
def subscribe_admins_to_group(group_id: int, user_ids: list[int]) -> Any:
    """Grant admin role in a group to one or more users."""
    payload = [{"id": uid} for uid in user_ids]
    return _post(f"/groups/{group_id}/admin/subscribe", payload)


@mcp.tool()
def unsubscribe_admins_from_group(group_id: int, user_ids: list[int]) -> Any:
    """Revoke admin role in a group from one or more users."""
    payload = [{"id": uid} for uid in user_ids]
    return _post(f"/groups/{group_id}/admin/unsubscribe", payload)


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    mcp.run()
