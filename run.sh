if [ "$2" = "makefile" ]; then
	echo "Makefile found, launching..."
	make run
	exit
fi

type=`echo "$1" | grep -o '\..*'`
name=`echo "$1" | grep -o '.*\.' | grep -o '.*[^\.]'`

if [ "$type" = ".cpp" ] || [ "$type" = ".c" ]; then
	echo "Launching a.out..."
	./a.out
elif [ "$type" = ".java" ]; then
	echo "Launching $name"
	java "$name"
elif [ "$type" = ".sh" ]; then
	bash $1
elif [ "$type" = ".vhd" ]; then
	ghdl -r $name
elif [ "$type" = ".py" ]; then
	python "$name.py"
fi
