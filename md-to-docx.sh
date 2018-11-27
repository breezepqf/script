name=`ls *.md | grep '.*md' | grep -o '.*\.' | grep -o '.*[^\.]'`
num=`echo "$name" | wc -l`
echo "$num markdown source(s) found."
for i in $(seq $num); do
	cnt=`echo "$name" | sed -n ${i}p`
	echo "Converting $cnt.md to $cnt.docx..."
	pandoc -o $cnt.docx -f markdown -t docx $cnt.md
done
echo "Done."
