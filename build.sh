if [ "$2" = "makefile" ]; then
	echo "Makefile found, making..."
	make -j 100
	exit
fi

type=`echo "$1" | grep -o '\..*'`

if [ "$type" = ".cpp" ] || [ "$type" = ".h" ] || [ "$type" = ".hpp" ]; then
	echo "Compiling using g++..."
	g++ $1 -O2 --std=c++11 && echo "$1 successfully compiled."
elif [ "$type" = ".c" ]; then
	echo "Compiling using gcc..."
	gcc $1 -O2 && echo "$1 successfully compiled."
elif [ "$type" = ".java" ]; then
	echo "Compiling using javac..."
	javac $1 && echo "$1 successfully compiled."
elif [ "$type" = ".sh" ]; then
	echo "Shell scripts can not be compiled."
fi
