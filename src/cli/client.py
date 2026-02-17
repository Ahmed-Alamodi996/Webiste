"""HTTP client wrapper for CLI -> API communication."""

import os
import sys
from typing import Any

import httpx
from rich.console import Console

console = Console()

DEFAULT_BASE_URL = "http://localhost:8000/api/v1"
TOKEN_FILE = os.path.expanduser("~/.ra-platform/token")


def _get_base_url() -> str:
    return os.environ.get("RA_API_URL", DEFAULT_BASE_URL)


def _load_token() -> str | None:
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE) as f:
            return f.read().strip()
    return os.environ.get("RA_TOKEN")


def save_token(token: str) -> None:
    os.makedirs(os.path.dirname(TOKEN_FILE), exist_ok=True)
    with open(TOKEN_FILE, "w") as f:
        f.write(token)
    os.chmod(TOKEN_FILE, 0o600)


def clear_token() -> None:
    if os.path.exists(TOKEN_FILE):
        os.remove(TOKEN_FILE)


def api_request(
    method: str,
    path: str,
    json_data: dict[str, Any] | None = None,
    params: dict[str, Any] | None = None,
    require_auth: bool = True,
) -> dict[str, Any] | list[Any]:
    """Make an authenticated API request."""
    base = _get_base_url()
    url = f"{base}{path}"
    headers: dict[str, str] = {"Content-Type": "application/json"}

    if require_auth:
        token = _load_token()
        if not token:
            console.print(
                "[red]Not authenticated.[/red] Run [bold]ra login[/bold] first."
            )
            sys.exit(1)
        headers["Authorization"] = f"Bearer {token}"

    try:
        with httpx.Client(timeout=60.0) as client:
            resp = client.request(
                method, url, json=json_data, params=params, headers=headers
            )

        if resp.status_code == 401:
            console.print(
                "[red]Session expired.[/red] Run [bold]ra login[/bold] to re-authenticate."
            )
            sys.exit(1)

        if resp.status_code >= 400:
            error_body = resp.json() if resp.headers.get("content-type", "").startswith("application/json") else {}
            msg = error_body.get("message", error_body.get("detail", resp.text))
            console.print(f"[red]API Error ({resp.status_code}):[/red] {msg}")
            sys.exit(1)

        return resp.json()

    except httpx.ConnectError:
        console.print(
            f"[red]Connection failed.[/red] Cannot reach API at [bold]{base}[/bold]\n"
            "Set RA_API_URL or start the platform with [bold]ra server start[/bold]."
        )
        sys.exit(1)
