echo Initializing git
git init
touch README.md
touch LICENSE
echo
echo Enter Copyright year
read copyright_year
echo
echo Enter Copyright holder
read copyright_holder
echo
echo "Copyright (c) $copyright_year $copyright_holder

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE." >> LICENSE

git add --all
git commit -m "Initial commit"

echo Enter repository name:
read reponame
git remote add origin https://github.com/<YourGitHubSite>/"$reponame".git
# curl -u 'dcorns' https://api.github.com/user/repos -d '{"name":"dcorns/bash_scripts.git"}'
curl -u '<YourGitHubUserName>' https://api.github.com/user/repos -d '{"name":"$reponame".git}'

git push -u origin master

git branch testing



