## Motions

```
w - (w)ord forward
b - word (b)ackward
e - (e)nd of word
$ - end of line
0 - beginning of line

s - (s)entence
{} - paragraph front and back

[]()<>""''`` - various blocks
% - jump from selected parenthesis/etc to matching far end
```

## Jumping

```
f<char> - (f)ind a character infront, move to it
F<char> - (f)ind a character behind, move to it
t<char> - move un(t)il a character infront, 1 char before it
T<char> - move un(t)il a character behind, 1 char infront of it

<space> - search for word forwards
```

## Spanning multiple lines

```
H - (h)igh position in window
M - (m)iddle position in window
L - (l)ow position in window
ctrl-u - scroll (u)p
ctrl-d - scroll (d)own
:<line> - jump to line

G - end of file
gg - beginning of file
ctrl-g - show file status
```




## Useful combinations

```
ci" - change inside quotes (or etc)
:s/bad/good/g - ctrl+h bad -> good on current line
:%s/bad/good/gc - ctrl+h bad -> good in entire file, with prompt
:.!date - replace current line with the date

> < - indent block (visual)
ctrl-t ctrl-d - indent current line (ins)
```

