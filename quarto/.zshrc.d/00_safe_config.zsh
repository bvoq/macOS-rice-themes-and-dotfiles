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

  print "→ quarto check jupyter"
  quarto check jupyter
}