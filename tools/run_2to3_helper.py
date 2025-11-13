# Small helper to run lib2to3 refactor on a source tree
import shutil
import os
import sys
from lib2to3.refactor import RefactoringTool, get_fixers_from_package

def main(src, dst):
    if not os.path.isdir(src):
        print('source not found:', src)
        sys.exit(2)
    if os.path.exists(dst):
        print('removing existing dst:', dst)
        shutil.rmtree(dst)
    print('copying', src, '->', dst)
    shutil.copytree(src, dst)
    fixers = get_fixers_from_package('lib2to3.fixes')
    rt = RefactoringTool(fixers)
    failures = 0
    for root, dirs, files in os.walk(dst):
        for fname in files:
            if not fname.endswith('.py'):
                continue
            path = os.path.join(root, fname)
            try:
                with open(path, 'r', encoding='utf-8') as fh:
                    src_text = fh.read()
                new = rt.refactor_string(src_text, path)
                with open(path, 'w', encoding='utf-8') as fh:
                    fh.write(str(new))
            except Exception as e:
                print('ERROR while refactoring', path, e)
                failures += 1
    print('done. failures=', failures)
    return failures

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: python run_2to3_helper.py <src> <dst>')
        sys.exit(1)
    sys.exit(main(sys.argv[1], sys.argv[2]))
