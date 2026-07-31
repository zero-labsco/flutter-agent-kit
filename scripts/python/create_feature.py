#!/usr/bin/env python3
"""create_feature.py — scaffolds a feature-first folder under lib/features.
create_feature.py — 在 lib/features 下生成「功能优先」结构的目录骨架。

Usage:  python scripts/python/create_feature.py <feature_name>
用法：  python scripts/python/create_feature.py <feature_name>
Example: python scripts/python/create_feature.py auth
示例：  python scripts/python/create_feature.py auth
Creates: lib/features/auth/{data,domain,presentation}/ with a barrel file.
生成：  lib/features/auth/{data,domain,presentation}/，并附 barrel 导出文件。
"""

import os
import re
import sys

NAME_RE = re.compile(r"^[a-z][a-z0-9_]*$")


def main(argv):
    if len(argv) < 1:
        sys.stderr.write("Usage: python scripts/python/create_feature.py <feature_name>\n")
        return 1

    name = argv[0].strip()
    if not NAME_RE.match(name):
        sys.stderr.write("Feature name must be snake_case starting with a letter.\n")
        return 1

    base = os.path.join(os.getcwd(), "lib", "features", name)

    for layer in ("data", "domain", "presentation"):
        layer_dir = os.path.join(base, layer)
        os.makedirs(layer_dir, exist_ok=True)
        # Place a barrel per layer for convenient imports.
        # 每个分层放置一个 barrel 文件，方便统一导入。
        with open(os.path.join(layer_dir, "{}_{}.dart".format(name, layer)),
                  "w", encoding="utf-8") as f:
            f.write("// {} {} layer.\n".format(name, layer))

    # Feature-level barrel.
    # 功能级 barrel 文件，统一导出各分层。
    with open(os.path.join(base, "{}.dart".format(name)), "w", encoding="utf-8") as f:
        f.write(
            "export '{name}/data/{name}_data.dart';\n"
            "export '{name}/domain/{name}_domain.dart';\n"
            "export '{name}/presentation/{name}_presentation.dart';\n".format(name=name)
        )

    print('Created feature "{}" at lib/features/{}'.format(name, name))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
