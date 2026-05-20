#!/bin/bash
# Check if ssh-agent is running, if not, start it
eval "$(ssh-agent -s)"
# Check if there is an existing SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "Generating SSH key..."
  ssh-keygen -t rsa -b 4096 -C "diogoandre1111@gmail.com"
fi
# Add SSH private key to ssh-agent
ssh-add ~/.ssh/id_rsa
# Display the public key
echo "Your public SSH key is:"
cat ~/.ssh/id_rsa.pub
# Prompt the user to add the SSH key to GitHub
echo "Please copy the above SSH key and add it to your GitHub account."
echo "Follow this link to add your SSH key: https://github.com/settings/keys"