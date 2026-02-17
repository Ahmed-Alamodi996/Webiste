"""YAML config management - import/export/validate config files."""

import json
import sys
from pathlib import Path

import click
from rich.console import Console

console = Console()


@click.group("yaml")
def yaml() -> None:
    """Manage platform config via YAML files (human-friendly alternative to JSON)."""
    pass


@yaml.command("export")
@click.argument("output_dir", default="./config_export")
@click.option("--format", "-f", "fmt", type=click.Choice(["yaml", "json"]), default="yaml")
def export_config(output_dir: str, fmt: str) -> None:
    """Export all platform configs to YAML/JSON files."""
    from src.cli.client import api_request

    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    # Export table configs
    data = api_request("GET", "/config/tables", params={"page_size": 1000})
    items = data.get("items", []) if isinstance(data, dict) else data
    _write_config(out / f"table_configs.{fmt}", items, fmt)
    console.print(f"  [green]Exported {len(items)} table configs[/green]")

    # Export connections
    data = api_request("GET", "/config/connections", params={"page_size": 1000})
    items = data.get("items", []) if isinstance(data, dict) else data
    _write_config(out / f"connections.{fmt}", items, fmt)
    console.print(f"  [green]Exported {len(items)} connections[/green]")

    # Export jobs
    data = api_request("GET", "/jobs", params={"page_size": 1000})
    items = data.get("items", []) if isinstance(data, dict) else data
    _write_config(out / f"jobs.{fmt}", items, fmt)
    console.print(f"  [green]Exported {len(items)} jobs[/green]")

    console.print(f"\n[bold green]All configs exported to {out}/[/bold green]")


@yaml.command("import")
@click.argument("config_file", type=click.Path(exists=True))
@click.option("--type", "-t", "config_type", required=True, type=click.Choice(["tables", "connections", "jobs"]))
@click.option("--dry-run", is_flag=True, help="Validate only, don't import")
@click.confirmation_option(prompt="Import configs? This will create new entries.")
def import_config(config_file: str, config_type: str, dry_run: bool) -> None:
    """Import configs from a YAML/JSON file."""
    from src.cli.client import api_request
    from src.config.yaml_loader import load_config_file, validate_config

    items = load_config_file(config_file)
    errors = validate_config(items, config_type)

    if errors:
        console.print("[red]Validation errors:[/red]")
        for err in errors:
            console.print(f"  [red]- {err}[/red]")
        if not dry_run:
            sys.exit(1)
        return

    console.print(f"[green]Validation passed: {len(items)} items[/green]")

    if dry_run:
        console.print("[dim]Dry run - no changes made.[/dim]")
        return

    endpoint_map = {
        "tables": "/config/tables",
        "connections": "/config/connections",
        "jobs": "/jobs",
    }
    endpoint = endpoint_map[config_type]

    success = 0
    failed = 0
    for item in items:
        try:
            api_request("POST", endpoint, json_data=item)
            success += 1
        except SystemExit:
            failed += 1

    console.print(f"\n[bold]Import complete:[/bold] {success} created, {failed} failed")


@yaml.command("validate")
@click.argument("config_file", type=click.Path(exists=True))
@click.option("--type", "-t", "config_type", required=True, type=click.Choice(["tables", "connections", "jobs"]))
def validate_yaml(config_file: str, config_type: str) -> None:
    """Validate a YAML/JSON config file without importing."""
    from src.config.yaml_loader import load_config_file, validate_config

    items = load_config_file(config_file)
    errors = validate_config(items, config_type)

    if errors:
        console.print(f"[red]Found {len(errors)} validation errors:[/red]")
        for err in errors:
            console.print(f"  [red]- {err}[/red]")
        sys.exit(1)
    else:
        console.print(f"[green]Valid! {len(items)} {config_type} definitions found.[/green]")


@yaml.command("template")
@click.argument("config_type", type=click.Choice(["tables", "connections", "jobs"]))
@click.option("--output", "-o", default=None, help="Output file path")
def generate_template(config_type: str, output: str | None) -> None:
    """Generate a YAML config template with examples."""
    from src.config.yaml_loader import get_template

    template = get_template(config_type)
    if output:
        Path(output).write_text(template)
        console.print(f"[green]Template written to {output}[/green]")
    else:
        console.print(template)


def _write_config(path: Path, data: list, fmt: str) -> None:
    if fmt == "yaml":
        try:
            import yaml
            with open(path, "w") as f:
                yaml.dump(data, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
        except ImportError:
            # Fallback to JSON if PyYAML not installed
            fmt = "json"
            path = path.with_suffix(".json")
            with open(path, "w") as f:
                json.dump(data, f, indent=2, default=str)
    else:
        with open(path, "w") as f:
            json.dump(data, f, indent=2, default=str)
