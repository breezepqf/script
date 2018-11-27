for i in $(seq ${2}); do
	printf "Test case ${i}:"
	time sh -c "./a.out < ${1}${i}.in > output"
	diff ${1}$i.ans output && echo "Accepted!"
	rm output
	echo
done
