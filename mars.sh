#!/bin/bash

# Setup password
yes $(pwgen 8 1 | tee passwd) | vncpasswd

# Get Mars jar
if [ ! -f ./Mars4_5.jar ]; then
    wget https://courses.missouristate.edu/KenVollmar/mars/MARS_4_5_Aug2014/Mars4_5.jar
fi

# Run server
vncserver :0  >/dev/null 2>&1 &
git worktree add $HOME/novnc novnc
$HOME/novnc/utils/novnc_proxy >/dev/null 2>&1 &

# Display instructions
cat <<EOF
Instructions:
1. make sure port 6080 is forwarded and visibility set to PUBLIC
2. go to the forwarded address select vnc.html
3. enter the password $(cat passwd)
4. enjoy!
EOF

# Run Mars
DISPLAY=:0 java -jar ./Mars4_5.jar

# Clean up
git worktree remove --force $HOME/novnc
rm passwd
kill $(jobs -p)
