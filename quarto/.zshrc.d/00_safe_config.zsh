# Note, favorite theme is lux followed by sandstone

quarto_course_create() {
  if ! command -v quarto >/dev/null 2>&1; then
    print -u2 "error: quarto not found on PATH"
    return 1
  fi

  if [[ $# -lt 1 || $# -gt 2 ]]; then
    print -u2 "usage: quarto_course_create <directory> [title]"
    return 1
  fi

  local course_dir=$1
  local course_name=${course_dir:t}
  local course_title=${2:-${course_name//-/ }}

  if [[ -e $course_dir ]]; then
    print -u2 "error: $course_dir already exists"
    return 1
  fi

  quarto create project book "$course_dir" || return 1

  cat > "$course_dir/_quarto.yml" <<YAML
project:
  type: book
  output-dir: ./

lang: de

toc: true
toc-depth: 3
number-sections: true
number-depth: 3

book:
  title: "${course_title}"
  author: "Kevin De Keyser"
  date: today
  downloads: [pdf, epub]
  output-file: "${course_name}"
  page-navigation: true
  sidebar:
    background: light
    search: true
    style: docked
  chapters:
    - index.qmd
    - intro.qmd
    - summary.qmd
    - references.qmd

bibliography: references.bib

format:
  docx:
    toc: true
  epub:
    syntax-highlighting: idiomatic
    toc: true
  html:
    anchor-sections: true
    citations-hover: true
    code-copy: true
    code-fold: true
    code-tools: true
    crossrefs-hover: true
    footnotes-hover: true
    html-math-method: katex
    link-external-icon: true
    link-external-newwindow: true
    smooth-scroll: true
    syntax-highlighting: kate
    theme:
      - lux
      - sandstone
  pdf:
    documentclass: scrreprt
    syntax-highlighting: idiomatic
  typst:
    toc: true
    syntax-highlighting: idiomatic

execute:
  echo: true
  warning: false
  message: false
YAML

  print "Created German Quarto course: $course_dir"
  print "Try: cd $course_dir && quarto preview"
}

quarto_python_init() {
  if ! command -v quarto >/dev/null 2>&1; then
    print -u2 "error: quarto not found on PATH"
    return 1
  fi
  if ! typeset -f mkvenv >/dev/null 2>&1; then
    print -u2 "error: mkvenv not found (zsh-autoswitch-virtualenv loaded?)"
    return 1
  fi

  # Quarto project marker
  if [[ ! -f _quarto.yml ]]; then
    print "→ no _quarto.yml; running quarto create project"
    quarto create project || return 1
  fi

  # Virtualenv
  if [[ -z ${VIRTUAL_ENV:-} ]]; then
    print "→ mkvenv"
    mkvenv || return 1
  fi
  if [[ -z ${VIRTUAL_ENV:-} && -d .venv && -f .venv/bin/activate ]]; then
    source .venv/bin/activate
  fi
  if [[ -z ${VIRTUAL_ENV:-} && -f .venv && -n ${VIRTUAL_ENV_DIR:-} ]]; then
    local venv_name=$(<.venv)
    local venv_activate="$VIRTUAL_ENV_DIR/$venv_name/bin/activate"
    if [[ -f $venv_activate ]]; then
      source "$venv_activate" || return 1
    fi
  fi
  if [[ -z ${VIRTUAL_ENV:-} || ! -d $VIRTUAL_ENV ]]; then
    print -u2 "error: virtualenv was not activated"
    return 1
  fi

  print "→ pip install jupyter stack"
  python -m pip install -U pip
  python -m pip install -U jupyter ipykernel pyyaml numpy matplotlib

  print "→ _environment"
  print -r -- "QUARTO_PYTHON=$VIRTUAL_ENV/bin/python" > _environment

  print "→ pyrightconfig.json"
  cat > pyrightconfig.json <<'JSON'
{
  "typeCheckingMode": "standard"
}
JSON

  python -m pip freeze > requirements.txt

  local starter="python-sample.qmd"
  if [[ -f $starter ]]; then
    print "→ $starter already exists (skip)"
  else
    print "→ write $starter"
    cat > "$starter" <<'QMD'
---
title: "Python sample"
format:
  html:
    code-fold: true
---

This document runs Python through Quarto's Jupyter integration.

```{python}
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(0, 2 * np.pi, 200)
y = np.sin(x)

fig, ax = plt.subplots()
ax.plot(x, y, label="sin(x)")
ax.set(xlabel="x", ylabel="y", title="A simple Python plot")
ax.legend()
plt.show()
```
QMD
  fi

  print "→ quarto check jupyter"
  quarto check jupyter
  print "OK. Try:"
  print "  quarto preview $starter"
}

# Quarto + p5.js (Observable JS) project bootstrap
quarto_p5_init() {
  if ! command -v quarto >/dev/null 2>&1; then
    print -u2 "error: quarto not found on PATH"
    return 1
  fi

  if [[ ! -f _quarto.yml ]]; then
    print "→ no _quarto.yml; running quarto create project"
    quarto create project || return 1
  fi

  if [[ ! -f _quarto.yml ]]; then
    print -u2 "error: _quarto.yml still missing after create project"
    return 1
  fi

  local starter="p5-sketch.qmd"
  if [[ -f $starter ]]; then
    print "→ $starter already exists (skip)"
  else
    print "→ write $starter"
    cat > "$starter" <<'QMD'
---
title: "p5.js sketch"
format:
  html:
    code-fold: true
    include-in-header:
      - text: |
          <script src="https://cdn.jsdelivr.net/npm/p5@2.3.1/lib/p5.min.js"></script>
---

Load p5 in an `{ojs}` cell, then run sketches in **instance mode**
(so multiple canvases can coexist on one page).

```{ojs}
// p5 from CDN via Observable's require()
P5 = window.p5

// helper: mount a sketch into its own div
function* createSketch(sketch) {
  const element = DOM.element("div");
  yield element;
  const instance = new P5(sketch, element, true);
  try {
    while (true) {
      yield element;
    }
  } finally {
    instance.remove();
  }
}

// example sketch
createSketch((s) => {
  s.setup = function () {
    s.createCanvas(400, 400);
    s.background(20);
    s.fill(220, 60, 60);
    s.circle(200, 200, 120);
  };
});
```

## D3 example

```{ojs}
d3 = require("d3@7")

{
  const width = 320;
  const height = 120;
  const data = [4, 8, 15, 16, 23, 42];

  const x = d3.scaleBand()
    .domain(d3.range(data.length))
    .range([0, width])
    .padding(0.1);

  const y = d3.scaleLinear()
    .domain([0, d3.max(data)])
    .range([height, 0]);

  const svg = d3.create("svg")
    .attr("width", width)
    .attr("height", height);

  svg.selectAll("rect")
    .data(data)
    .join("rect")
    .attr("x", (_, i) => x(i))
    .attr("y", (d) => y(d))
    .attr("width", x.bandwidth())
    .attr("height", (d) => height - y(d))
    .attr("fill", "steelblue");

  yield svg.node();
}
```
QMD
  fi

  print "→ quarto check"
  quarto check
  print "OK. Try:"
  print "  quarto preview $starter"
  print "  # or from nvim: open $starter and :QSyncPreview / <leader>qs"
}