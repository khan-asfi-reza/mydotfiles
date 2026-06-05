for script in ~/.bashscripts/*.sh; do
  [[ "$script" == *"init.sh" ]] && continue
  [ -f "$script" ] && source "$script"
done
