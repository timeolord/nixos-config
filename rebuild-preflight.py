#!/usr/bin/env python3

import json
import hashlib
import os
import re
import sqlite3
import subprocess
import sys
import tempfile


CACHE_PATH = '/etc/nixos/rebuild-size-cache.json'
STATE_VERSION = 1


def package_fingerprint(flake, limit):
    root, host = flake.rsplit('#', 1)
    root = root.removeprefix('path:')
    tokens = re.compile(r'"(?:\\.|[^"\\])*"|\'\'(?:(?!\'\').)*\'\'|/\*.*?\*/|\#[^\n]*|[a-zA-Z_][\w\'-]*|[^\s]', re.S)
    relevant = []
    for directory, dirs, files in os.walk(root):
        dirs[:] = sorted(d for d in dirs if not d.startswith('.') and d != '__pycache__')
        for name in sorted(files):
            if not name.endswith('.nix'):
                continue
            path = os.path.join(directory, name)
            with open(path, encoding='utf-8') as source:
                parts = [t for t in tokens.findall(source.read()) if not t.startswith(('#', '/*'))]
            found = []
            for i, part in enumerate(parts):
                if part == 'pkgs' and i + 2 < len(parts) and parts[i + 1] == '.':
                    end = i + 3
                    while end + 1 < len(parts) and parts[end] == '.':
                        end += 2
                    found.append(parts[i:end])
                if part in ('package', 'packages', 'systemPackages', 'extraPackages', 'addons', 'buildInputs', 'nativeBuildInputs', 'dependencies') and i + 1 < len(parts) and parts[i + 1] == '=':
                    end = i + 2
                    depth = 0
                    with_scope = False
                    while end < len(parts):
                        if parts[end] == 'with' and depth == 0:
                            with_scope = True
                        if parts[end] in ('[', '(', '{'):
                            depth += 1
                        elif parts[end] in (']', ')', '}'):
                            depth -= 1
                        elif parts[end] == ';' and depth == 0:
                            if not with_scope:
                                break
                            with_scope = False
                        end += 1
                    found.append(parts[i:end + 1])
            if found:
                relevant.append([os.path.relpath(path, root), found])
    with open(os.path.join(root, 'flake.lock'), encoding='utf-8') as lock:
        inputs = json.load(lock)
    data = [STATE_VERSION, host, inputs, relevant, limit, os.environ.get('REBUILD_SUBSTITUTERS'), os.environ.get('REBUILD_TRUSTED_KEYS')]
    return hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()


def state_path(flake):
    base = os.environ.get('XDG_CACHE_HOME') or os.path.expanduser('~/.cache')
    host = flake.rsplit('#', 1)[-1]
    return os.path.join(base, 'rebuild-system', hashlib.sha256(host.encode()).hexdigest() + '.json')


def checked_fingerprint(path):
    try:
        with open(path, encoding='utf-8') as state:
            return json.load(state).get('fingerprint')
    except (OSError, ValueError, AttributeError):
        return None


def save_fingerprint(path, fingerprint):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=os.path.dirname(path), delete=False) as state:
        try:
            json.dump({'fingerprint': fingerprint}, state)
            temp_path = state.name
        except BaseException:
            os.unlink(state.name)
            raise
    try:
        os.replace(temp_path, path)
    finally:
        if os.path.exists(temp_path):
            os.unlink(temp_path)


def package_name(path):
    name = os.path.basename(path)[33:].removesuffix('.drv')
    if name.endswith(('_fish-completions', '-fish-completions', '-env')):
        return None
    match = re.match(r'^(.*?)-(?=\d)', name)
    return match.group(1) if match else None


def run_command(args):
    return subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def size_history():
    try:
        with open(CACHE_PATH, encoding='utf-8') as cache:
            history = json.load(cache)
        if not isinstance(history, dict) or any(not isinstance(name, str) or type(size) is not int or size <= 0 for name, size in history.items()):
            raise ValueError('invalid cache format')
    except FileNotFoundError:
        history = {}
    builds = {}
    with sqlite3.connect('file:/nix/var/nix/db/db.sqlite?mode=ro', uri=True) as db:
        rows = db.execute('select deriver, narSize from ValidPaths where deriver is not null and narSize > 0')
        for drv, size in rows:
            builds[drv] = builds.get(drv, 0) + size
    changed = False
    for drv, size in builds.items():
        name = package_name(drv)
        if name and size > history.get(name, 0):
            history[name] = size
            changed = True
    if changed:
        with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=os.path.dirname(CACHE_PATH), delete=False) as cache:
            temp_path = cache.name
            try:
                json.dump(history, cache, sort_keys=True, indent=2)
                cache.write('\n')
            except BaseException:
                os.unlink(temp_path)
                raise
        try:
            os.replace(temp_path, CACHE_PATH)
        finally:
            if os.path.exists(temp_path):
                os.unlink(temp_path)
    return history


def main():
    if len(sys.argv) != 2:
        print('usage: rebuild-preflight.py FLAKE | --refresh-cache', file=sys.stderr)
        return 1
    try:
        limit = int(os.environ.get('REBUILD_SIZE_LIMIT_MIB', '768')) * 1024 * 1024
        if limit <= 0:
            raise ValueError
    except ValueError:
        print('REBUILD_SIZE_LIMIT_MIB must be a positive integer', file=sys.stderr)
        return 1

    if sys.argv[1] != '--refresh-cache':
        try:
            fingerprint = package_fingerprint(sys.argv[1], limit)
            state = state_path(sys.argv[1])
            if os.environ.get('REBUILD_FORCE_PLAN') != '1' and checked_fingerprint(state) == fingerprint:
                print('package inputs unchanged since the last planner check; skipping')
                return 0
        except (OSError, ValueError, TypeError) as error:
            print(f'could not check package inputs, running planner: {error}', file=sys.stderr)
            fingerprint = None

    try:
        history = size_history()
    except (OSError, sqlite3.Error, ValueError) as error:
        print(f'could not update package size history: {error}', file=sys.stderr)
        return 1
    if sys.argv[1] == '--refresh-cache':
        print(f'cached sizes for {len(history)} packages')
        return 0

    command = [
        'sudo', 'nix', 'build', '--dry-run', '--no-link', '--no-write-lock-file',
        '--log-format', 'internal-json',
    ]
    if os.environ.get('REBUILD_SUBSTITUTERS'):
        command += ['--option', 'extra-substituters', os.environ['REBUILD_SUBSTITUTERS']]
    if os.environ.get('REBUILD_TRUSTED_KEYS'):
        command += ['--option', 'extra-trusted-public-keys', os.environ['REBUILD_TRUSTED_KEYS']]
    command.append(sys.argv[1] + '.config.system.build.toplevel')
    print('checking the rebuild plan for large local builds...', flush=True)
    plan = run_command(command)
    if plan.returncode:
        print(plan.stderr, file=sys.stderr)
        return plan.returncode

    derivations = []
    for line in plan.stderr.splitlines():
        if line.startswith('@nix '):
            event = json.loads(line[5:])
            message = event.get('msg', '').strip()
            if event.get('action') == 'msg' and message.startswith('/nix/store/') and message.endswith('.drv'):
                derivations.append(message)
    if not derivations:
        print('no local builds are planned')
        if fingerprint:
            try:
                save_fingerprint(state, fingerprint)
            except OSError as error:
                print(f'could not save planner state: {error}', file=sys.stderr)
        return 0

    blocked = False
    unversioned = 0
    for drv in derivations:
        name = package_name(drv)
        if name is None:
            unversioned += 1
            continue
        previous = history.get(name)
        label = os.path.basename(drv)[33:].removesuffix('.drv')
        if previous is None:
            print(f'[info] {label}: no previous package size available')
        elif previous >= limit:
            print(f'[large] {label}: largest known output was {previous / 1024**2:.1f} MiB')
            blocked = True
    if unversioned:
        print(f'[info] {unversioned} unversioned or generated build steps have no size estimate')
    if blocked:
        print(f'rebuild stopped: known output size reached {limit // 1024**2} MiB', file=sys.stderr)
        return 1
    if fingerprint:
        try:
            save_fingerprint(state, fingerprint)
        except OSError as error:
            print(f'could not save planner state: {error}', file=sys.stderr)
    return 0


if __name__ == '__main__':
    sys.exit(main())
