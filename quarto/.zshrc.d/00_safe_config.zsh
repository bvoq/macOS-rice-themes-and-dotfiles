# Note, favorite theme is lux followed by sandstone

quarto_course_create() {
  if ! command -v quarto > /dev/null 2>&1; then
    print -u2 "error: quarto not found on PATH"
    return 1
  fi
  if ! command -v yq > /dev/null 2>&1; then
    print -u2 "error: yq not found on PATH"
    return 1
  fi

  if [[ $# -lt 1 || $# -gt 2 ]]; then
    print -u2 "usage: quarto_course_create <directory> [title]"
    return 1
  fi

  local course_dir=${1:A}
  local course_parent=${course_dir:h}
  local course_name=${course_dir:t}
  local course_title=${2:-${course_name//-/ }}
  local quarto_config="$course_dir/_quarto.yml"
  local bibliography="$course_dir/references.bib"
  local created_project=false

  if [[ ! -e $course_dir ]]; then
    mkdir -p "$course_parent" || return 1
    pushd "$course_parent" > /dev/null || return 1
    quarto create project book "$course_name" --no-prompt --no-open
    local create_exit=$?
    popd > /dev/null || return 1
    ((create_exit == 0)) || return 1
    created_project=true
  elif [[ ! -d $course_dir ]]; then
    print -u2 "error: $course_dir exists but is not a directory"
    return 1
  fi

  if [[ ! -f $quarto_config ]]; then
    print -u2 "error: missing Quarto configuration: $quarto_config"
    return 1
  fi

  COURSE_NAME="$course_name" COURSE_TITLE="$course_title" yq -i '
    .project.type = "book" |
    .project."output-dir" = "./" |
    .lang = "de" |
    .toc = true |
    ."toc-depth" = 3 |
    ."number-sections" = true |
    ."number-depth" = 3 |
    .book.title = strenv(COURSE_TITLE) |
    .book.author = "Kevin De Keyser" |
    .book.date = "today" |
    .book.downloads = ["pdf", "epub"] |
    .book."output-file" = strenv(COURSE_NAME) |
    .book."page-navigation" = true |
    .book.sidebar.background = "light" |
    .book.sidebar.search = true |
    .book.sidebar.style = "docked" |
    .bibliography = "references.bib" |
    .format.docx.toc = true |
    .format.epub."syntax-highlighting" = "idiomatic" |
    .format.epub.toc = true |
    .format.html."anchor-sections" = true |
    .format.html."citations-hover" = true |
    .format.html."code-copy" = true |
    .format.html."code-fold" = true |
    .format.html."code-tools" = true |
    .format.html."crossrefs-hover" = true |
    .format.html."footnotes-hover" = true |
    .format.html."html-math-method" = "katex" |
    .format.html."include-in-header" = (((.format.html."include-in-header" // []) | map(select(.text != "<script src=\"https://cdn.jsdelivr.net/npm/p5@2.3.1/lib/p5.min.js\"></script>\n"))) + [{"text": "<script src=\"https://cdn.jsdelivr.net/npm/p5@2.3.1/lib/p5.min.js\"></script>\n"}]) |
    .format.html."link-external-icon" = true |
    .format.html."link-external-newwindow" = true |
    .format.html."smooth-scroll" = true |
    .format.html."syntax-highlighting" = "kate" |
    .format.html.theme = ["lux", "sandstone"] |
    .format.pdf.documentclass = "scrreprt" |
    .format.pdf."syntax-highlighting" = "idiomatic" |
    .format.typst.toc = true |
    .format.typst."syntax-highlighting" = "idiomatic" |
    .execute.echo = true |
    .execute.warning = false |
    .execute.message = false
  ' "$quarto_config" || return 1

  if [[ -f $course_dir/cover.png ]]; then
    yq -i '.book.image = "cover.png"' "$quarto_config" || return 1
  fi

  if [[ ! -e $bibliography ]]; then
    : > "$bibliography" || return 1
  elif [[ ! -f $bibliography ]]; then
    print -u2 "error: bibliography exists but is not a file: $bibliography"
    return 1
  fi

  if [[ $created_project == true ]]; then
    print "Created and configured German Quarto course: $course_dir"
  else
    print "Patched German Quarto course configuration: $quarto_config"
  fi
  print "Try: cd $course_dir && quarto preview"
}

quarto_python_init() {
  if ! command -v quarto > /dev/null 2>&1; then
    print -u2 "error: quarto not found on PATH"
    return 1
  fi
  if ! typeset -f mkvenv > /dev/null 2>&1; then
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
    local venv_name=$(< .venv)
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
  cat > pyrightconfig.json << 'JSON'
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
    cat > "$starter" << 'QMD'
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
  if ! command -v quarto > /dev/null 2>&1; then
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
    cat > "$starter" << 'QMD'
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
