import importlib, sys, traceback
try:
    m = importlib.import_module('ib')
    print('ib module:', getattr(m, '__file__', str(m)))
    s = importlib.import_module('ib.opt.connection')
    print('ib.opt.connection loaded:', s.__file__)
except Exception as e:
    print('IMPORT ERROR', type(e).__name__, e)
    traceback.print_exc()
    sys.exit(2)
