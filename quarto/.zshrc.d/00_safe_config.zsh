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
  VENV_PATH=${VIRTUAL_ENV:h} VENV_NAME=${VIRTUAL_ENV:t} python - <<'PY'
import json
import os

with open("pyrightconfig.json", "w", encoding="utf-8") as config:
    json.dump(
        {"venvPath": os.environ["VENV_PATH"], "venv": os.environ["VENV_NAME"]},
        config,
        indent=2,
    )
    config.write("\n")
PY

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