#!/usr/bin/env python3
import json
import sys
import re
from pathlib import Path
from argparse import ArgumentParser, RawDescriptionHelpFormatter

def parse_args():
    parser = ArgumentParser(description="Update VSCode JSON configs from Makefile variables")
    parser.add_argument("--target", required=True)
    parser.add_argument("--build-dir", required=True)
    parser.add_argument("--includes", required=True)
    parser.add_argument("--defs", required=True)
    parser.add_argument("--gcc-path", required=True)
    parser.add_argument("--cflags", required=True)
    parser.add_argument("--gdb-path", required=True)
    parser.add_argument("--openocd-bin", required=True)
    parser.add_argument("--openocd-interface", required=True)
    parser.add_argument("--openocd-target", required=True)
    parser.add_argument("--svd-file", required=True)
    parser.add_argument("--size-path", required=True)
    parser.add_argument("--processor-count", type=int, default=0)
    return parser.parse_args()

def split_args(s):
    return [x for x in s.split() if x]

def update_json_file(path, updater):
    path = Path(path)
    if not path.exists():
        print(f"Warning: {path} not found, skipping")
        return
    with open(path, 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    updated = updater(data)
    if updated:
        with open(path, 'w', encoding='utf-8-sig') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        print(f"Updated {path}")

def update_c_cpp_properties(data, args):
    if not data.get("configurations"):
        return False
    cfg = data["configurations"][0]
    changed = False
    if cfg.get("name") != args.target:
        cfg["name"] = args.target
        changed = True
    # includePath
    includes = [f"${{workspaceFolder}}/{p}/**" for p in split_args(args.includes)]
    if cfg.get("includePath") != includes:
        cfg["includePath"] = includes
        changed = True
    # defines
    defs = split_args(args.defs)
    if cfg.get("defines") != defs:
        cfg["defines"] = defs
        changed = True
    # compilerPath
    if cfg.get("compilerPath") != args.gcc_path:
        cfg["compilerPath"] = args.gcc_path
        changed = True
    # compilerArgs
    cflags_list = split_args(args.cflags)
    if cfg.get("compilerArgs") != cflags_list:
        cfg["compilerArgs"] = cflags_list
        changed = True
    return changed

def update_launch(data, args):
    if not data.get("configurations"):
        return False
    cfg = data["configurations"][0]
    changed = False
    # executable
    elf = f"{args.build_dir}/{args.target}.elf"
    if cfg.get("executable") != elf:
        cfg["executable"] = elf
        changed = True
    # gdbPath
    if cfg.get("gdbPath") != args.gdb_path:
        cfg["gdbPath"] = args.gdb_path
        changed = True
    # serverpath
    if cfg.get("serverpath") != args.openocd_bin:
        cfg["serverpath"] = args.openocd_bin
        changed = True
    # configFiles – два файла
    config_files = [args.openocd_interface]
    if args.openocd_target:
        config_files.append(args.openocd_target)
    if cfg.get("configFiles") != config_files:
        cfg["configFiles"] = config_files
        changed = True
    # svdFile
    if cfg.get("svdFile") != args.svd_file:
        cfg["svdFile"] = args.svd_file
        changed = True
    return changed

def update_tasks(data, args):
    changed = False
    for task in data.get("tasks", []):
        label = task.get("label")
        # Обновляем пути в задаче Build Analyzer
        if label == "Build Analyzer":
            args_list = task.get("args", [])
            new_args = []
            for arg in args_list:
                if arg.endswith(".elf"):
                    new_args.append(f"{args.build_dir}/{args.target}.elf")
                elif arg.endswith(".map"):
                    new_args.append(f"{args.build_dir}/{args.target}.map")
                else:
                    new_args.append(arg)
            if args_list != new_args:
                task["args"] = new_args
                changed = True
                
        cmd = task.get("command", "")
        if isinstance(cmd, str) and " -j" in cmd:
            new_cmd = re.sub(r'-j\s*\d+', f'-j{args.processor_count}', cmd)
            if new_cmd != cmd:
                task["command"] = new_cmd
                changed = True
    return changed

def main():
    args = parse_args()
    if args.processor_count == 0:
        import os
        args.processor_count = os.cpu_count() or 1

    update_json_file(".vscode/c_cpp_properties.json",
                     lambda data: update_c_cpp_properties(data, args))
    update_json_file(".vscode/launch.json",
                     lambda data: update_launch(data, args))
    update_json_file(".vscode/tasks.json",
                     lambda data: update_tasks(data, args))

if __name__ == "__main__":
    main()
