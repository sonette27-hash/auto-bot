#requires -version 5.0
<#
.SYNOPSIS
    Setup environment script for IbPy 2.0.8 demo and development.

.DESCRIPTION
    This script automates:
    1. Creating a Python virtual environment (.venv)
    2. Installing the IbPy package from the archived source
    3. Running a dry-run test of the demo to verify setup
    4. Displaying environment info for debugging

.PARAMETER SkipDryRun
    If specified, skip the dry-run test after setup.

.PARAMETER PythonExe
    Path to Python executable (default: 'python' from PATH).

.EXAMPLE
    .\setup-env.ps1                    # Full setup + dry-run test
    .\setup-env.ps1 -SkipDryRun        # Setup only, no test
    .\setup-env.ps1 -PythonExe "C:\Python311\python.exe"

.NOTES
    Requires:
    - Python 3.8+ (or Python 2.7, though unmaintained)
    - pip (included with Python)
    - PowerShell 5.0+
    - Windows environment (uses .venv\Scripts\Activate.ps1)

    Logs: See console output; no log file written.
#>

param(
    [switch]$SkipDryRun,
    [string]$PythonExe = "python"
)

# Colors for output
$InfoColor = "Cyan"
$SuccessColor = "Green"
$ErrorColor = "Red"
$WarningColor = "Yellow"

function Write-Info { Write-Host $args[0] -ForegroundColor $InfoColor }
function Write-Success { Write-Host $args[0] -ForegroundColor $SuccessColor }
function Write-Error-Custom { Write-Host "ERROR: $($args[0])" -ForegroundColor $ErrorColor }
function Write-Warning-Custom { Write-Host "WARNING: $($args[0])" -ForegroundColor $WarningColor }

Write-Info "================================"
Write-Info "IbPy 2.0.8 Environment Setup"
Write-Info "================================"

# ========== STEP 1: Check Python availability ==========
Write-Info "`n[1/5] Checking Python..."
try {
    $PythonVersion = & $PythonExe --version 2>&1
    Write-Success "✓ Python found: $PythonVersion"
} catch {
    Write-Error-Custom "Python executable not found at '$PythonExe'. Make sure Python is installed and on PATH."
    exit 1
}

# ========== STEP 2: Create virtual environment ==========
Write-Info "`n[2/5] Setting up virtual environment..."
$VenvPath = ".venv"

if (Test-Path $VenvPath) {
    Write-Warning-Custom "Virtual environment already exists at '$VenvPath'. Skipping creation."
} else {
    try {
        & $PythonExe -m venv $VenvPath
        if ($LASTEXITCODE -ne 0) {
            throw "venv creation failed with exit code $LASTEXITCODE"
        }
        Write-Success "✓ Virtual environment created at '$VenvPath'"
    } catch {
        Write-Error-Custom "Failed to create virtual environment: $_"
        exit 1
    }
}

# ========== STEP 3: Activate virtual environment ==========
Write-Info "`n[3/5] Activating virtual environment..."
$ActivateScript = "$VenvPath\Scripts\Activate.ps1"
if (-not (Test-Path $ActivateScript)) {
    Write-Error-Custom "Activation script not found at '$ActivateScript'"
    exit 1
}

try {
    & $ActivateScript
    Write-Success "✓ Virtual environment activated"
} catch {
    Write-Error-Custom "Failed to activate virtual environment: $_"
    exit 1
}

# ========== STEP 4: Install IbPy from archive ==========
Write-Info "`n[4/5] Installing IbPy from archived source..."
$PackagePath = "extracted\IbPy2-0.8.0"

if (-not (Test-Path $PackagePath)) {
    Write-Error-Custom "Package path not found: '$PackagePath'. Make sure the archive has been extracted."
    exit 1
}

try {
    Push-Location $PackagePath
    Write-Info "   Installing from: $(Get-Location)"
    
    # Ensure setuptools and wheel are available (needed for legacy setup.py)
    Write-Info "   Ensuring setuptools and wheel are available..."
    & python -m pip install --upgrade setuptools wheel 2>&1 | Out-Null
    
    # Try setup.py install first (legacy); fall back to pip install .
    Write-Info "   Attempting: python setup.py install"
    $setupOutput = & python setup.py install 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Package installed (setup.py)"
    } else {
        Write-Warning-Custom "setup.py install returned exit code $LASTEXITCODE. Trying: pip install ."
        & python -m pip install . 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Both installation methods failed. Try in a venv with Python 3.8-3.11 (Python 3.12+ removed distutils)."
        }
        Write-Success "✓ Package installed (pip)"
    }
    
    Pop-Location
} catch {
    Write-Error-Custom "Failed to install IbPy: $_"
    exit 1
}

# ========== STEP 5: Verify installation ==========
Write-Info "`n[5/5] Verifying installation..."
try {
    $VerifyOutput = python -c "from ib.opt import Connection; print('IbPy import OK')" 2>&1
    if ($VerifyOutput -match "IbPy import OK") {
        Write-Success "✓ IbPy import verified"
    } else {
        Write-Error-Custom "Import verification failed: $VerifyOutput"
        exit 1
    }
} catch {
    Write-Error-Custom "Failed to verify installation: $_"
    exit 1
}

# ========== SUMMARY ==========
Write-Success "`n✓ Environment setup complete!"
Write-Info "`nEnvironment Info:"
Write-Info "  Python: $(& python --version)"
Write-Info "  Venv: $VenvPath"
Write-Info "  Package: $PackagePath"

# ========== DRY-RUN TEST (optional) ==========
if ($SkipDryRun) {
    Write-Info "`n-SkipDryRun specified. Test skipped."
    Write-Info "To run demo manually:"
    Write-Info "  `$env:IBPY_DEMO_DRY_RUN=1"
    Write-Info "  python demo\ib_api_demo.py"
    exit 0
}

Write-Info "`n================================"
Write-Info "Running Dry-Run Test..."
Write-Info "================================"

$env:IBPY_DEMO_DRY_RUN = 1
try {
    Write-Info "Executing: python demo\ib_api_demo.py (with IBPY_DEMO_DRY_RUN=1)"
    Write-Info ""
    
    & python demo\ib_api_demo.py
    if ($LASTEXITCODE -eq 0) {
        Write-Success "`n✓ Dry-run test PASSED"
        Write-Info "`nNext steps:"
        Write-Info "  1. Start Trader Workstation (TWS) or IB Gateway"
        Write-Info "  2. Enable API in TWS: Configure → API → Enable Socket Clients on port 7496"
        Write-Info "  3. Run live demo: python demo\ib_api_demo.py"
        Write-Info ""
        Write-Info "For detailed instructions, see: extracted\IbPy2-0.8.0\QUICK_START.md"
    } else {
        Write-Error-Custom "Dry-run test FAILED (exit code $LASTEXITCODE)"
        exit 1
    }
} catch {
    Write-Error-Custom "Dry-run test raised exception: $_"
    exit 1
}

Write-Success "`n✓ All setup steps completed successfully!"
