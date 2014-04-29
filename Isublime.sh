#sublime-text3 install with package control requires argument containing path to tarball

echo 'Installing sublime text'
#sudo yum -y install wget
#change this line to latest or desired tarball locations
#sudo wget c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3059_x64.tar.bz2
#change this line to match the name of the tarball
#subl=sublime_text_3_build_3059_x64.tar.bz2
#sudo tar jxvf "$subl"
#sudo rm "$subl"
#if the directory created by extraction changes, so should this line
#         copy launcher for sublime
#sudo cp sublime_text_3/sublime_text.desktop /usr/share/applications/

#rename sublime and move to /opt
#sudo mv -f sublime_text_3 /opt/sublime

#       Make Sublime Executable from Terminal
#cd /usr/local/sbin
#sudo ln -s /opt/sublime/sublime_text subl

#       Set Sublime user preferences
#sudo mkdir -p ~/.config/sublime-text-3/Packages/User
#sudo mkdir -p ~/.config/sublime-text-3/'Installed Packages'
#sudo chmod 777 ~/.config/sublime-text-3/Packages/User
#cd ~/.config/sublime-text-3/Packages/User
#sudo echo touch Preferences.sublime-settings
#sudo echo '{' >> Preferences.sublime-settings
#sudo echo '"ensure_newline_at_eof_on_save" '': true,' >> Preferences.sublime-settings
#sudo echo '"save_on_focus_lost" '': true,' >> Preferences.sublime-settings
#sudo echo '"tab_size" '': 2,' >> Preferences.sublime-settings
#sudo echo '"translate_tabs_to_spaces" '': true,' >> Preferences.sublime-settings
#sudo echo '"trim_trailing_white_space_on_save" '': true' >> Preferences.sublime-settings
#sudo echo '}' >> Preferences.sublime-settings
#       Sublime Package Control Install
# Note that google chrome will open to download the package, you must manually close, also if you have yet run google the first time their might be a problem downloading if this is run first

#google-chrome 'https://sublime.wbond.net/Package%20Control.sublime-package'
#sleep 5s
#cd ~/Downloads
sudo chmod 777 ~/.config/sublime-text-3 -R
#sudo mv 'Package Control.sublime-package' ~/.config/sublime-text-3/'Installed Packages/'
#       Make Sublime package File
cd ~/.config/sublime-text-3/Packages/User
touch 'Package Control.sublime-settings'
sudo echo '{' >> 'Package Control.sublime-settings'
sudo echo '     "installed_packages":' >> 'Package Control.sublime-settings'
sudo echo '     [' >> 'Package Control.sublime-settings'
sudo echo '               "BeautifyRuby",' >> 'Package Control.sublime-settings'
sudo echo '               "Browser Refresh",' >> 'Package Control.sublime-settings'
sudo echo '               "Emmet",' >> 'Package Control.sublime-settings'
sudo echo '               "Four Spaces JavaScript (snippets)",' >> 'Package Control.sublime-settings'
sudo echo '               "Gist",' >> 'Package Control.sublime-settings'
sudo echo '               "GitGutter",' >> 'Package Control.sublime-settings'
sudo echo '               "Handlebars",' >> 'Package Control.sublime-settings'
sudo echo '               "Jade",' >> 'Package Control.sublime-settings'
sudo echo '               "JavaScript & NodeJS Snippets",' >> 'Package Control.sublime-settings'
sudo echo '               "Javascript Beautify",' >> 'Package Control.sublime-settings'
sudo echo '               "JavaScript Patterns",' >> 'Package Control.sublime-settings'
sudo echo '               "JavaScript Refactor",' >> 'Package Control.sublime-settings'
sudo echo '               "JavaScript Snippets",' >> 'Package Control.sublime-settings'
sudo echo '               "JavaScriptNext - ES6 Syntax",' >> 'Package Control.sublime-settings'
sudo echo '               "jQuery Snippets pack",' >> 'Package Control.sublime-settings'
sudo echo '               "JS Snippets",' >> 'Package Control.sublime-settings'
sudo echo '               "JS Var Shortcuts",' >> 'Package Control.sublime-settings'
sudo echo '               "JsFormat",' >> 'Package Control.sublime-settings'
sudo echo '               "JSHint Gutter",' >> 'Package Control.sublime-settings'
sudo echo '               "JsonTree",' >> 'Package Control.sublime-settings'
sudo echo '               "SASS Snippets",' >> 'Package Control.sublime-settings'
sudo echo '               "SassBeautify",' >> 'Package Control.sublime-settings'
sudo echo '               "SideBarEnhancements",' >> 'Package Control.sublime-settings'
sudo echo '               "SublimeGit",' >> 'Package Control.sublime-settings'
sudo echo '               "sublimelint",' >> 'Package Control.sublime-settings'
sudo echo '               "SublimeLinter-jshint",' >> 'Package Control.sublime-settings'
sudo echo '               "SublimeREPL",' >> 'Package Control.sublime-settings'
sudo echo '               "UnitJS"' >> 'Package Control.sublime-settings'
sudo echo '     ]' >> 'Package Control.sublime-settings'
sudo echo '}' >> 'Package Control.sublime-settings'
echo 'Sublime Text install complete'



