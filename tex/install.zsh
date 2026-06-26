TEX_VARIANT=LIGHT # LIGHT or FULL

phase_1_admin_installs() {
  case "$TEX_VARIANT" in
    LIGHT)
      install_brewfile tex/Brewfile.light
      ;;
    FULL)
      install_brewfile tex/Brewfile.full
      ;;
    *)
      echo "Unknown TEX_VARIANT: $TEX_VARIANT (expected LIGHT or FULL)"
      return 1
      ;;
  esac
}
