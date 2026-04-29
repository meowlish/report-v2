#!/usr/bin/env python3
import csv
import sys
import re
import os

SKIP_COLS = {0, 8, 9}  # Pages (1), Test Case Result (9), Status (10) — 0-indexed

HEADER_VI = [
    "Phân loại",
    "Mã TC",
    "Mô tả",
    "Điều kiện tiên quyết",
    "Các bước kiểm thử",
    "Dữ liệu kiểm thử",
    "Kết quả mong đợi",
]

COL_SPEC = (
    r"|>{\raggedright\arraybackslash}p{1.6cm}"
    r"|>{\raggedright\arraybackslash}p{1.4cm}"
    r"|>{\raggedright\arraybackslash}p{3.2cm}"
    r"|>{\raggedright\arraybackslash}p{2.8cm}"
    r"|>{\raggedright\arraybackslash}p{4.5cm}"
    r"|>{\raggedright\arraybackslash}p{3.0cm}"
    r"|>{\raggedright\arraybackslash}p{4.5cm}|"
)


def escape_latex(s: str) -> str:
    s = s.replace("\\", r"\textbackslash{}")
    s = s.replace("&", r"\&")
    s = s.replace("%", r"\%")
    s = s.replace("$", r"\$")
    s = s.replace("#", r"\#")
    s = s.replace("_", r"\_")
    s = s.replace("{", r"\{")
    s = s.replace("}", r"\}")
    s = s.replace("~", r"\textasciitilde{}")
    s = s.replace("^", r"\textasciicircum{}")
    s = s.replace('"', "''")
    s = s.replace("—", "---")
    s = s.replace("–", "--")
    return s


def format_cell(s: str) -> str:
    s = s.strip()
    if not s:
        return ""
    s = escape_latex(s)
    lines = s.split("\n")
    lines = [l.strip() for l in lines if l.strip()]
    if len(lines) <= 1:
        return lines[0] if lines else ""
    numbered = all(re.match(r"^\d+\.", l) for l in lines)
    if numbered:
        items = []
        for l in lines:
            l = re.sub(r"^\d+\.\s*", "", l)
            items.append(f"    \\item {l}")
        return (
            "\\begin{enumerate}[leftmargin=*, nosep, labelsep=0.3em]\n"
            + "\n".join(items)
            + "\n\\end{enumerate}"
        )
    return " \\newline\n".join(lines)


def convert_csv(csv_path: str, output_path: str, caption: str, label: str):
    with open(csv_path, encoding="utf-8") as f:
        reader = csv.reader(f)
        rows = list(reader)

    header = rows[0]
    data = rows[1:]

    visible_cols = [i for i in range(len(header)) if i not in SKIP_COLS]

    with open(output_path, "w", encoding="utf-8") as out:
        out.write("{\n")
        out.write("\\renewcommand{\\arraystretch}{1.3}\n")
        out.write("\\small\n")
        out.write("\\begin{landscape}\n")
        out.write(f"\\begin{{longtable}}{{{COL_SPEC}}}\n")
        out.write(f"\\caption{{{caption}}}\n")
        out.write(f"\\label{{{label}}} \\\\\n")
        out.write("\\hline\n")

        header_cells = " & ".join(
            f"\\textbf{{{h}}}" for h in HEADER_VI
        )
        out.write(f"{header_cells} \\\\\n")
        out.write("\\hline\n")
        out.write("\\endfirsthead\n\n")

        out.write("\\hline\n")
        out.write(f"{header_cells} \\\\\n")
        out.write("\\hline\n")
        out.write("\\endhead\n\n")

        out.write("\\hline\n")
        out.write("\\endfoot\n\n")

        for row in data:
            cells = []
            for i in visible_cols:
                val = row[i] if i < len(row) else ""
                cells.append(format_cell(val))
            out.write(" & ".join(cells) + " \\\\\n")
            out.write("\\hline\n")

        out.write("\\end{longtable}\n")
        out.write("\\end{landscape}\n")
        out.write("}\n")

    print(f"Generated {output_path} ({len(data)} rows)")


if __name__ == "__main__":
    base = os.path.dirname(os.path.abspath(__file__))

    convert_csv(
        os.path.join(base, "e2e-testcases.csv"),
        os.path.join(base, "e2e-testcases-table.tex"),
        "Danh sách test case E2E --- Lingriser",
        "tab:e2e-englishprep",
    )

    convert_csv(
        os.path.join(base, "e2e-lingriser-tcs-vi.csv"),
        os.path.join(base, "e2e-lingriser-table.tex"),
        "Danh sách test case E2E --- Lingriser",
        "tab:e2e-lingriser",
    )
