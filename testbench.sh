entity=`echo "$1" | grep -o '.*\.' | grep -o '.*[^\.]'`
content=`pcregrep -M "entity(\n|.)*?end" $1 | pcregrep -M "port(\n|.)*\);"`
header="library std;\n\
use std.textio.all;\n\n\
library ieee;\n\
use ieee.std_logic_1164.all;\n\
use ieee.std_logic_unsigned.all;\n\
use ieee.std_logic_textio.all;\n\n";

printf "$header";
echo "entity ${entity}_tb is"
echo "end ${entity};"
echo
echo "architecture ${entity}_tb_arch of ${entity}_tb is"
printf "\tcomponent ${entity}\n"
echo "$content"
printf "\tend component;\n"
echo "begin"
printf "\tprocess\n"
printf "\t\tvariable str: LINE;\n"
printf "\tbegin\n\n"
printf "\t\twait;\n"
printf "\tend process;\n"
echo "end ${entity}_tb_arch;"

