#!/usr/bin/env python3
"""把一个 course.json 注入 templates/base.html,输出单文件 HTML。

用法:
    python build.py <course.json> <output.html>
"""
import json, sys, pathlib

def main():
    if len(sys.argv) != 3:
        print("Usage: python build.py <course.json> <output.html>", file=sys.stderr)
        sys.exit(1)
    course_path, out_path = sys.argv[1], sys.argv[2]
    here = pathlib.Path(__file__).parent
    tpl = (here / "templates" / "base.html").read_text(encoding="utf-8")
    course = json.loads(pathlib.Path(course_path).read_text(encoding="utf-8"))

    # 占位符: const COURSE = /*{{COURSE_JSON}}*/ { ... };
    # 把 `/*{{COURSE_JSON}}*/ { placeholder }` 整段替换为真实 JSON
    import re
    pattern = re.compile(r"/\*\{\{COURSE_JSON\}\}\*/\s*\{[\s\S]*?\n\};", re.MULTILINE)
    replacement = json.dumps(course, ensure_ascii=False, indent=2) + ";"
    new_html = pattern.sub(lambda _: replacement, tpl, count=1)
    if new_html == tpl:
        print("❌ 未找到 COURSE_JSON 占位符,请检查 base.html", file=sys.stderr)
        sys.exit(2)
    new_html = new_html.replace("{{COURSE_TITLE}}", course.get("meta", {}).get("title", "Course"))

    pathlib.Path(out_path).write_text(new_html, encoding="utf-8")
    print(f"✓ 生成: {out_path}")

if __name__ == "__main__":
    main()
