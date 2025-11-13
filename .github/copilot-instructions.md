## Goal
## Purpose
Short, actionable guidance so an AI coding agent can be productive quickly in this repository: an archived IbPy release plus runnable demos.

## Big picture
- Archive: `extracted/IbPy2-0.8.0/` contains the IbPy package source (version 0.8.0). The project is an offline archive and demo set, not a modern Python package layout.
- Runtime: code communicates with TWS / IB Gateway over a TCP socket (ports 7496/7497). Expect asynchronous callbacks and long-running connections.

## Key files to read first
- `demo/ib_api_demo.py` — canonical demo showing Connection.create/connect, `register`/`registerAll`, placeOrder and disconnect. Also demonstrates `IBPY_DEMO_DRY_RUN` env var.
- `extracted/IbPy2-0.8.0/setup.py` — packaging/install instructions; uses 2to3 for Python3 builds.
- `extracted/IbPy2-0.8.0/ib/` — library source; edit here if you need to change library behavior and then reinstall.
- `.vscode/launch.json` — contains a `debugpy` configuration that prompts for a script path; useful for running demos under the debugger.

## Project-specific patterns & concrete examples
- Connection: Connection.create(port=7496, clientId=100); then `.connect()` and `.disconnect()`.
- Handlers: `tws_conn.register(error_handler, 'Error')` and `tws_conn.registerAll(reply_handler)` — handlers receive IbPy message objects.
- Order flow: create a Contract (see `create_contract` in demo), create Order (`create_order`), then `tws_conn.placeOrder(order_id, contract, order)`.
- Dry-run: set `IBPY_DEMO_DRY_RUN=1` to skip live TWS connection when experimenting.

## Developer workflows (PowerShell examples)
1) Create & activate virtualenv:
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```
2) Install archived package (from `extracted/IbPy2-0.8.0/`):
```powershell
cd extracted\IbPy2-0.8.0
python setup.py install   # legacy; or try: pip install .
```
3) Run demo from workspace root:
```powershell
python demo\ib_api_demo.py
```
4) Debug in VS Code: use the `debugpy` launch configuration **"Enable Claude Haiku 4.5 for all clients"** (in `.vscode/launch.json`):
   - Press F5 or go to Run → Start Debugging
   - When prompted "Enter the path to the Python script...", type: `demo\ib_api_demo.py`
   - Breakpoints will be honored; output appears in Integrated Terminal

## Integration notes & constraints
- TWS/IB Gateway must be running and have API access enabled; use the configured socket port.
- The archive targets older Python: `setup.py` uses 2to3 conversion when building for Python 3. Expect import or compatibility issues when modernizing.
- There are no automated tests included; demos are the primary smoke tests.

## Quick-start checklist
Before running any demo:
- [ ] **Venv ready?** Run `.\.venv\Scripts\Activate.ps1` (or create one if missing).
- [ ] **Package installed?** From `extracted\IbPy2-0.8.0\`, run `python setup.py install` (or `pip install .`).
- [ ] **TWS/Gateway running?** Start Trader Workstation or IB Gateway.
- [ ] **API enabled in TWS?** Check TWS → Configure → API → Enable socket connections on port 7496 (or 7497).
- [ ] **Try dry-run first:** `$env:IBPY_DEMO_DRY_RUN=1; python demo\ib_api_demo.py` (skips live connection).
- [ ] **Then live:** `python demo\ib_api_demo.py` (requires TWS running with API enabled).

For troubleshooting and detailed TWS setup steps, see `extracted/IbPy2-0.8.0/QUICK_START.md`.

## Key environment variables & connection parameters
- `IBPY_DEMO_DRY_RUN=1` — Skip live TWS connection in demos (useful for testing).
- `port=7496` — Default TWS API socket port (7497 is the backup/failover).
- `clientId=100` — Unique identifier for this client connection; use different values for execution vs. market-data connections.

### Sample environment variable usage (PowerShell)
```powershell
# Dry-run (no TWS required):
$env:IBPY_DEMO_DRY_RUN=1
python demo\ib_api_demo.py

# Override connection port (if TWS is on 7497):
$env:IB_PORT=7497
python demo\ib_api_demo.py

# Set multiple; then run:
$env:IBPY_DEMO_DRY_RUN=0
$env:IB_CLIENT_ID=101
python demo\ib_api_demo.py
```

## Editing conventions for agents
- Prefer small, local edits: add or update demos in `demo/` rather than modifying the tarball in place.
- If changing library code, edit under `extracted/IbPy2-0.8.0/ib/` and reinstall with `python setup.py install`.
- Preserve existing handler signatures and message registration patterns when modifying message processing.

If you'd like, I can (pick one): extract the tarball into a branch and add a README with step-by-step run/debug commands, or create a small Python3 compatibility PR. Tell me which and I will proceed.
