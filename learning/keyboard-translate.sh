#!/usr/bin/env bash

# translate source engine keybinds from one keyboard layout (e.g. QWERTY) to another (DVORAK / COLEMAK)

FILE='test.cfg'
rm -f $FILE
touch $FILE

qwerty='`1234567890\-=qwertyuiop[]\\asdfghjkl;'\''zxcvbnm,./'
dvorak='`1234567890[]'\'',.pyfgcrl/=\\aoeuidhtns\-;qjkxbmwvz'
colemak='`1234567890\-=qwfpgjluy;[]\\arstdhneio'\''zxcvbkm,./'

cat << EOF > $FILE
some_other_action 1
i will break this bad script with an invalid entry
this one has a 'funny' character
// i think this is how comments are formatted
// in cfg files, don't really remember
bind "a" "some_action 1"
bind "b" "some_action 1"
bind "c" "some_action 1"
bind "d" "some_action 1"
bind "e" "some_action 1"
bind "f" "some_action 1"
bind "g" "some_action 1"
bind "h" "some_action 1"
bind "i" "some_action 1"
bind "j" "some_action 1"
bind "k" "some_action 1"
bind "l" "some_action 1"
bind "m" "some_action 1"
bind "n" "some_action 1"
bind "o" "some_action 1"
bind "p" "some_action 1"
bind "q" "some_action 1"
bind "r" "some_action 1"
bind "s" "some_action 1"
bind "t" "some_action 1"
bind "u" "some_action 1"
bind "v" "some_action 1"
bind "w" "some_action 1"
bind "x" "some_action 1"
bind "y" "some_action 1"
bind "z" "some_action 1"
bind "SPACE" "another_action 2"
bind "KP_UP" "yet_another_one"
some_other_action 0
ignore_me_please 1
EOF

while IFS= read -r line; do
	if [[ $(echo "$line" | awk '{print $1}') == "bind" ]]; then
		echo "$line" | awk '{print $1}' | tr '\n' ' '
	else
		echo "$line"
		continue
	fi

	if [[ $(echo "$line" | awk '{print $2}' | wc -c) == 4 ]]; then
		#           change this variable between $dvorak and $colemak vvvvvvv
		echo "$line" | awk '{print $2}' | tr -d '"\n' | tr "$qwerty" "$dvorak" && printf " "
	else
		echo "$line" | awk '{print $2}' | tr '\n' ' '
	fi

	echo "$line" | cut -d' ' -f3-

done < "$FILE"


#cat $FILE
rm $FILE

