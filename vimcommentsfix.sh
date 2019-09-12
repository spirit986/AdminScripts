#!/bin/bash

## Fixes those dark blue vim comments on any system

cat >lightcomment.sh <<ENDTR
#!/bin/bash
mkdir -p ~/.vim/colors
touch ~/.vim/colors/lightcomment.vim
cat >~/.vim/colors/lightcomment.vim <<EOF
hi clear

if exists("syntax_on")
    syntax reset
endif

let colors_name = "lightcomment"
hi Comment  ctermfg=lightblue
EOF

if [ ! -f ~/.vimrc ]
then
	cat >>~/.vimrc <<EOF
syntax on
colorscheme lightcomment
EOF
else 
	echo ".vimrc has been detected. Edit the file manually and add the following lines:"
	echo
	echo "syntax on"
	echo "colorscheme lightcomment"
fi
ENDTR
chmod +x lightcomment.sh
./lightcomment.sh
