# IbPy 2.0.8 Quick Start & Troubleshooting

This guide covers installation, configuration, running demos, and common issues for IbPy 2.0.8 (archived release).

## Prerequisites

### 1. Python Environment
- **Recommended:** Python 3.8+ (the archive uses 2to3 converter for Python 3 compatibility).
- **Legacy:** Python 2.7 may work but is unmaintained.
- **Windows:** Ensure `python` and `pip` are on your PATH.

### 2. Trader Workstation (TWS) or IB Gateway
- **Download:** https://www.interactivebrokers.com/en/trading/platforms/tws.php
- **Setup:** Install and launch.
- **Next:** Proceed to **TWS Configuration** section below.

## TWS Configuration (Critical Step)

### Enable API Access in TWS — Visual Checklist

**Step 1: Open TWS Settings**
```
Trader Workstation (TWS) Main Window
  ↓
  [File] or [Configure] (menu bar)
  ↓
  Select "Global Configuration"
  (or "Configure" → "Settings")
  ↓
  Left sidebar: Click "API"
  ↓
  Select "Settings" tab
```

**Step 2: Verify & Enable these settings**

| Setting | Value | Status |
|---------|-------|--------|
| **Enable ActiveX and Socket Clients** | checked ✓ | ▢ Done |
| **Socket Port** | `7496` (or `7497`) | ▢ Done |
| **Read-Only API** | unchecked ✗ | ▢ Done |
| **Trusted Advisors Enabled** | (optional) | ▢ Done |

**Step 3: Apply & Restart**
```
[Apply] button (bottom of settings window)
↓
Restart TWS when prompted
↓
Look for: "Socket Client: connected" or "API ready" in logs
```

**Step 4: Verify Connection in Terminal**
```powershell
# From workspace root, dry-run first:
$env:IBPY_DEMO_DRY_RUN=1
python demo\ib_api_demo.py

# Expected: "IBPY_DEMO_DRY_RUN set — skipping live connect..."
# ✓ If this works, TWS config is good; now try live:
python demo\ib_api_demo.py

# Expected: Connection message, then order submission
```

### Common TWS Configuration Issues

| Issue | Fix |
|-------|-----|
| **"Read-Only API enabled"** | Uncheck "Read-Only API" in Settings if you plan to place orders. |
| **"Can't find API settings"** | In TWS, go **Configure** → look for "API" or "API Settings" (menu location varies by TWS version). |
| **"Port 7496 already in use"** | Use port `7497` instead, or check `netstat -an \| findstr 7496` to see what's using it. |
| **"Socket not listening"** | Restart TWS and watch logs for "Socket Client: connected" message. |

## Installation

### From this archive (two methods)

**Method 1: Using `setup.py` (legacy, what the demos expect)**
```powershell
# From this directory (IbPy2-0.8.0/):
python setup.py install
```

**Method 2: Using `pip install` (modern)**
```powershell
# From this directory:
pip install .
```

Both methods will:
- Convert Python 2 syntax to Python 3 (if using Python 3) via the 2to3 tool.
- Install the `ib` package into your virtual environment's site-packages.

### Verify installation
```powershell
python -c "from ib.opt import Connection; print('IbPy import OK')"
```

If that works, IbPy is ready.

#### Python 3.12+ Note
If using Python 3.12 or later and `setup.py install` fails with `ModuleNotFoundError: No module named 'distutils'`:
- Python 3.12 removed distutils from the standard library
- Workaround: Install setuptools: `python -m pip install setuptools`
- Or downgrade to Python 3.11: `pyenv install 3.11.9` or download from python.org

## Running the Demo

### 1. Dry-run (no TWS required)
```powershell
cd ..\..  # Go back to workspace root
$env:IBPY_DEMO_DRY_RUN=1
python demo\ib_api_demo.py
```

**Expected output:**
```
IBPY_DEMO_DRY_RUN set — skipping live connect/placeOrder (dry-run).
```

### 2. Live run (TWS must be running with API enabled)
```powershell
# Make sure TWS is running and API is enabled (port 7496)
python demo\ib_api_demo.py
```

**Expected behavior:**
- Connects to TWS on port 7496.
- Registers message handlers.
- Places a demo order (GOOG 100 shares market order).
- Waits for async responses (5 seconds).
- Disconnects.

**Output should look like:**
```
Creating Connection object...
Calling connect()...
Sleeping 2s to allow messages from TWS...
Placing order (demo)
Sleeping 5s to receive async replies...
Disconnecting...
```

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `IBPY_DEMO_DRY_RUN` | `1` | Skip live TWS connection; useful for testing without TWS running. |
| `PYTHONPATH` | (path to IbPy) | Add IbPy to import search path if not installed globally. |

### Sample Environment Variable Usage (PowerShell)

```powershell
# Dry-run mode (skip live TWS connection):
$env:IBPY_DEMO_DRY_RUN=1
python demo\ib_api_demo.py

# Override connection port (if TWS is listening on 7497):
$env:IB_PORT=7497
python demo\ib_api_demo.py

# Use a different client ID (for concurrent connections):
$env:IB_CLIENT_ID=101
python demo\ib_api_demo.py

# Combine multiple variables:
$env:IBPY_DEMO_DRY_RUN=0; $env:IB_CLIENT_ID=102; $env:IB_PORT=7496
python demo\ib_api_demo.py

# Clear a variable (revert to default):
Remove-Item env:IB_PORT
python demo\ib_api_demo.py  # Now uses default 7496
```

### Extended Variable Reference

| Variable | Default | Purpose | Example |
|----------|---------|---------|---------|
| `IBPY_DEMO_DRY_RUN` | (not set) | Skip live TWS connection if set to `1` | `$env:IBPY_DEMO_DRY_RUN=1` |
| `IB_PORT` | `7496` | Override TWS API socket port | `$env:IB_PORT=7497` |
| `IB_CLIENT_ID` | `100` | Unique client identifier; use different values for concurrent connections | `$env:IB_CLIENT_ID=101` |
| `PYTHONPATH` | (not set) | Add IbPy to Python import path if not installed | `$env:PYTHONPATH="C:\path\to\ib"` |

### Quick Batch Setup Example

```powershell
# Create a reusable test script: test-setup.ps1
$env:IBPY_DEMO_DRY_RUN=1
$env:IB_CLIENT_ID=999

Write-Host "Environment variables set:"
Get-ChildItem env:IB* | Select-Object Name, Value
Write-Host "`nRunning demo..."

python demo\ib_api_demo.py
```

Run with: `PowerShell -ExecutionPolicy Bypass -File test-setup.ps1`

## Troubleshooting

### Issue: `ImportError: No module named 'ib'`

**Cause:** IbPy package not installed in the active Python environment.

**Solutions:**
1. Verify venv is activated: `.\.venv\Scripts\Activate.ps1`
2. Reinstall from this directory: `python setup.py install`
3. Check installation: `pip list | grep -i ibpy` (should list IbPy2)

### Issue: `Connection refused` or `Connection timeout`

**Cause:** TWS/Gateway is not running or API port is wrong.

**Solutions:**
1. Start TWS or IB Gateway.
2. Verify TWS API port: TWS → Configure → API → Settings → Socket Port (should be 7496 or 7497).
3. Check firewall: Windows Firewall might block port 7496. Open it:
   ```powershell
   # Add rule (as Administrator):
   New-NetFirewallRule -DisplayName "TWS API Port 7496" -Direction Inbound -LocalPort 7496 -Protocol TCP -Action Allow
   ```

### Issue: `placeOrder` returns an error or order is silently rejected

**Cause:** API is in read-only mode, or TWS requires authentication.

**Solutions:**
1. In TWS, go to Configure → API → Settings and **uncheck** "Read-Only API".
2. Ensure you are logged in with a live trading account (or paper trading account).
3. Check TWS logs for rejection reason: look at the message window in TWS.

### Issue: `2to3 not found` when running `python setup.py install`

**Cause:** 2to3 is not available in your Python environment (rare in Python 3.3+).

**Solutions:**
1. Upgrade Python: `python --version` (aim for Python 3.8+).
2. Manually convert syntax (advanced):
   ```powershell
   2to3 -w -n ib/  # (if 2to3 is available separately)
   ```
3. Or use the modern `pip install .` method instead:
   ```powershell
   pip install .  # (may handle conversion automatically)
   ```

### Issue: `AttributeError: 'Contract' has no attribute 'm_...'`

**Cause:** Wrong IbPy version or import path; the `ib.ext.Contract` object uses `m_` prefix for attributes (legacy design).

**Solutions:**
1. Verify import: `from ib.ext.Contract import Contract`
2. Check version: `python -c "import ib; print(ib.__version__)"`
3. See `demo/ib_api_demo.py` for correct attribute names (e.g., `contract.m_symbol`).

## Code Examples

### Minimal connection + disconnect
```python
from ib.opt import Connection

tws_conn = Connection.create(port=7496, clientId=100)
tws_conn.connect()
print("Connected!")
time.sleep(1)
tws_conn.disconnect()
print("Disconnected.")
```

### Registering handlers
```python
def error_handler(msg):
    print(f"Error: {msg}")

def reply_handler(msg):
    print(f"Reply: {msg}")

tws_conn.register(error_handler, 'Error')
tws_conn.registerAll(reply_handler)
tws_conn.connect()
time.sleep(2)  # Wait for async callbacks
```

### Placing an order
```python
from ib.ext.Contract import Contract
from ib.ext.Order import Order

# Create contract
contract = Contract()
contract.m_symbol = 'AAPL'
contract.m_secType = 'STK'
contract.m_exchange = 'SMART'
contract.m_primaryExch = 'SMART'
contract.m_currency = 'USD'

# Create order
order = Order()
order.m_orderType = 'MKT'
order.m_totalQuantity = 100
order.m_action = 'BUY'

# Submit
tws_conn.placeOrder(1, contract, order)
```

## Next Steps

- **Explore the library:** Look at `ib/ext/` (Contract, Order, etc.) and `ib/opt/Connection` for available classes.
- **Read the demo:** `demo/ib_api_demo.py` is the canonical example.
- **Check IB docs:** https://www.interactivebrokers.com/en/trading/platforms/api.php for API reference.
- **Advanced:** For production use, consider error handling, reconnection logic, and async message queue management.

## Support & Resources

- **IB API Reference:** https://www.interactivebrokers.com/en/trading/platforms/api.php
- **Original IbPy GitHub:** https://github.com/blampe/IbPy (archived; this is version 0.8.0 from that repository).
- **Interactive Brokers Support:** https://www.interactivebrokers.com/en/support/

---

**Last updated:** November 14, 2025  
**IbPy Version:** 0.8.0  
**Python:** 3.8+ (with 2to3 build support for Python 2 source)
