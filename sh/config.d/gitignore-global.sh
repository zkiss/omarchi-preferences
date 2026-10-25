# ensure global gitignore exists
excludes=`git config --global --get core.excludesfile`
if [ -z "$excludes" ]; then
	excludes=~/.gitignore-global
	git config --global core.excludesfile $excludes
fi
if [ ! -f $excludes ]; then
	touch $excludes
fi
