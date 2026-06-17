#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os

def get_relative_path(abs_path, base_dir):
    """Возвращает относительный путь от base_dir, заменяя \\ на /."""
    rel = os.path.relpath(abs_path, base_dir)
    return rel.replace('\\', '/')

def collect_files(base_dir, extension):
    """Собирает все файлы c заданным расширением в base_dir (рекурсивно).
       Возвращает список относительных путей (в Unix-стиле)."""
    files = []
    for root, dirs, filenames in os.walk(base_dir):
        for f in filenames:
            if f.endswith(extension):
                full_path = os.path.join(root, f)
                rel_path = get_relative_path(full_path, base_dir)
                files.append(rel_path)
    files.sort()
    return files

def collect_include_dirs(base_dir):
    """Собирает уникальные пути к папкам, содержащим .h файлы.
       Возвращает отсортированный список относительных путей c завершающим '/'."""
    include_dirs_set = set()
    for root, dirs, filenames in os.walk(base_dir):
        for f in filenames:
            if f.endswith('.h'):
                rel_dir = get_relative_path(root, base_dir)
                if rel_dir:
                    include_dirs_set.add(rel_dir + '/')
                else:
                    include_dirs_set.add('./')
    return sorted(include_dirs_set)

def print_variable(name, items, trailing_slash=False):
    """
    Выводит переменную Makefile с переносами.
    name - имя переменной (например, "C_SOURCES")
    items - список строк (путей или папок)
    trailing_slash - если True, добавляет '/' в конце каждого элемента (для INCLUDES)
    """
    print(f"{name} = \\")
    if not items:
        print()
        return
    count = len(items)
    for i, item in enumerate(items):
        if trailing_slash and not item.endswith('/'):
            item += '/'
        if i < count - 1:
            print(f"{item} \\")
        else:
            print(item)
    print()

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    print("Find files for Makefile v1.0")
    print()

    c_files = collect_files(script_dir, '.c')
    print_variable("C_SOURCES", c_files)

    s_files = collect_files(script_dir, '.s')
    print_variable("ASM_SOURCES", s_files)

    include_dirs = collect_include_dirs(script_dir)
    print_variable("C_INCLUDES", include_dirs, trailing_slash=True)

    ld_files = collect_files(script_dir, '.ld')
    print_variable("LDSCRIPT", ld_files)

if __name__ == "__main__":
    main()