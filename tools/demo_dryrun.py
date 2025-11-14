#!/usr/bin/env python3
import os
import traceback

dry = os.environ.get("IBPY_DEMO_DRY_RUN") not in (None, "", "0")
print("IBPY_DEMO_DRY_RUN =", dry)

try:
    import ib
    print("ib package:", getattr(ib, "__file__", str(ib)))

    from ib.opt import connection
    con = connection.Connection.create()
    print("Created Connection:", con)
    print("Connection host,port,clientId:", con.host, con.port, con.clientId)

    # Try to register a harmless error handler (register should be local)
    def on_error(id=None, errorCode=None, errorMsg=None):
        print("ERROR handler called:", id, errorCode, errorMsg)

    if hasattr(con, "register"):
        try:
            con.register(on_error)
            print("Registered on_error handler")
        except Exception as e:
            print("con.register() raised:", repr(e))
    else:
        print("Connection has no register() method")

    # Inspect message types (quick sanity check)
    try:
        from ib.opt import message
        print("messageTypeNames count:", len(message.messageTypeNames()))
    except Exception as e:
        print("message import/inspection raised:", repr(e))

    if dry:
        print("Dry-run: skipping network connect and requests.")
    else:
        print("Live mode: attempting connect() (may fail if TWS not running).")
        try:
            res = con.connect()
            print("connect() returned:", res)
        except Exception as e:
            print("connect() failed:", repr(e))

    print("Demo dry-run finished.")
except Exception:
    traceback.print_exc()
    raise
