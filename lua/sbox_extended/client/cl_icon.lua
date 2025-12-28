local Icons = {}
function sAndbox.CreateIcon(name, dir)
	Icons[name] = Material(dir, "smooth noclamp mips")
end

function sAndbox.GetIcon(name)
	return Icons[name]
end

sAndbox.CreateIcon("health", "icons/health.png")
sAndbox.CreateIcon("cup", "icons/cup.png")
sAndbox.CreateIcon("food", "icons/food.png")