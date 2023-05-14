matrix_size=9

## Functions
function reload_waybar {
	kill -SIGRTMIN+1 $(pgrep waybar)
}

function clamp {
	echo $(($1 > matrix_size ? matrix_size : $(($1 < 1 ? 1 : $1))))
}

function x_value {
	echo $((($1 - 1 & 255) + 1))
}

function y_value {
	echo $((($1 - 1 >> 8) + 1))
}

function show_all {
	hyprctl workspaces -j | jq '.[]."id"' | sort -g | while read id; do echo -n "($(x_value $id),$(y_value $id)) "; done
}

## Check for command "all"
case "$1" in
	"all") show_all; exit ;;
esac;

## Get active workspace and translate to x / y

active_ws=$(hyprctl monitors -j | jq '.[]."activeWorkspace"."id"')

#echo $active_ws 1>&2
x=$(x_value $active_ws)
y=$(y_value $active_ws)

#echo "($x,$y)" 1>&2

case "$1" in
	"left" | "move_left") x=$(clamp $(($x - 1))) ;;
	"right" | "move_right") x=$(clamp $(($x + 1))) ;;
	"up" | "move_up") y=$(clamp $(($y - 1))) ;;
	"down" | "move_down") y=$(clamp $(($y + 1))) ;;
	"query") echo "($x,$y)"; exit ;;
esac

#echo "($x,$y)" 1>&2

## Generate new workspace number
ws=$(( $(( (y-1) << 8 )) + x ))
#echo $ws 1>&2

case "$1" in
	"left" | "right" | "up" | "down") hyprctl dispatch workspace $ws ;;
	"move_left" | "move_right" | "move_up" | "move_down") hyprctl dispatch movetoworkspace $ws ;;
esac

reload_waybar
