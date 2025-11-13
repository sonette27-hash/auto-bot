# Python Environment Requirements for IbPy 2.0.8

## Minimum Requirements

- **Python:** 3.8–3.11 (recommended); Python 3.12+ has compatibility issues with legacy `distutils`
- **pip:** Latest (included with Python)
- **Operating System:** Windows, Linux, or macOS (tested on Windows)

## Package Dependencies

IbPy 2.0.8 has **no external runtime dependencies** beyond Python standard library.

The archived package is self-contained; it does not require:
- NumPy
- Pandas
- Requests
- Or any other third-party libraries

All import paths are from the bundled `ib/` module and Python stdlib.

## Installation Methods

### Method 1: Using `setup.py` (Legacy, Recommended for this archive)

```powershell
cd extracted\IbPy2-0.8.0
python setup.py install
```

**What it does:**
- Runs 2to3 converter to convert Python 2 syntax to Python 3 (if using Python 3)
- Installs the `ib` package into your virtual environment's `site-packages/`

### Method 2: Using `pip` (Modern Alternative)

```powershell
cd extracted\IbPy2-0.8.0
pip install .
```

**What it does:**
- Similar to Method 1 but uses pip as the installer
- May handle 2to3 conversion automatically on Python 3

## Virtual Environment Setup

```powershell
# Create
python -m venv .venv

# Activate (PowerShell)
.\.venv\Scripts\Activate.ps1

# Activate (cmd.exe)
.venv\Scripts\activate.bat

# Deactivate
deactivate
```

**Or use the automated setup script:**
```powershell
.\setup-env.ps1
```

## Compatibility Notes

### Python 3.8–3.11
- ✓ Fully supported
- ✓ Both `setup.py install` and `pip install .` work
- ✓ Recommended choice

### Python 3.12+
- ⚠ **distutils was removed**, causing `setup.py install` to fail
- ⚠ Workaround: Use `pip install .` with setuptools installed, or downgrade to Python 3.11
- ⚠ Not recommended unless you have setuptools/distutils compatibility layer installed

### Python 2.7
- ⚠ Works but unmaintained
- ⚠ Legacy; not recommended for new projects
- ⚠ Some imports and modules may differ from Python 3 versions

## Runtime Environment Variables

No required environment variables; all are optional:

| Variable | Purpose | Example |
|----------|---------|---------|
| `PYTHONPATH` | Add custom import paths | `$env:PYTHONPATH="C:\my\custom\path"` |
| `IBPY_DEMO_DRY_RUN` | Skip TWS connection in demos | `$env:IBPY_DEMO_DRY_RUN=1` |
| `IB_PORT` | Override TWS API port (custom) | `$env:IB_PORT=7497` |
| `IB_CLIENT_ID` | Override client ID (custom) | `$env:IB_CLIENT_ID=101` |

## Verification

```powershell
# Check installation
python -c "from ib.opt import Connection; print('OK')"

# Check version
python -c "import ib; print(ib.__version__)"

# List installed packages
pip list | findstr /i ibpy
```

## Troubleshooting

### Issue: `ModuleNotFoundError: No module named 'ib'`

**Solution:**
1. Ensure venv is activated: `.\.venv\Scripts\Activate.ps1`
2. Reinstall: `cd extracted\IbPy2-0.8.0; python setup.py install`
3. Verify PATH: `python -c "import sys; print(sys.path)"`

### Issue: `SyntaxError` in IbPy code during import

**Solution:**
1. Ensure you are using Python 3.8+
2. Reinstall with 2to3 conversion: `python setup.py install --force`
3. Alternatively, use: `pip install --force-reinstall .`

### Issue: `Permission denied` during install

**Solution (Windows):**
1. Run PowerShell as Administrator
2. Or install to user site: `pip install --user .`

## Next Steps

- See `QUICK_START.md` for detailed setup, configuration, and troubleshooting
- See `.github/copilot-instructions.md` for AI agent guidance
- See `demo/ib_api_demo.py` for example usage

## References

- **Python Official:** https://www.python.org/
- **venv Documentation:** https://docs.python.org/3/library/venv.html
- **IbPy GitHub (archived):** https://github.com/blampe/IbPy

---

**Last updated:** November 14, 2025  
**IbPy Version:** 0.8.0
