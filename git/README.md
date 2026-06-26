Locate your .ssh location.
Normally on Windows/macOS/unix this is: ~/.ssh
On some versions of Windows it might be in: C:\Program Files\Git\etc\ssh\

Create keys in the appropriate location:
ssh-keygen -t ed25519 -C "your_email@example.com" -f $HOME/.ssh/id_myid
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f $HOME/.ssh/id_myid

Set .ssh/config as follows:
Host github.mycompany.com
    HostName github.mycompany.com
    IdentityFile ~/.ssh/id_mycompany
    IdentitiesOnly yes

If you have two different keys for the same host you can use:
Host github.com-repo1
    HostName github.com
    IdentityFile ~/.ssh/id_keyforrepo1
    IdentitiesOnly yes

Host github.com-repo2
    HostName github.com
    IdentityFile ~/.ssh/id_keyforrepo2
    IdentitiesOnly yes

Note that you will have to clone the repo respectively as:
git clone "git@github.com-repo1/user/repo1.git"
git clone "git@github.com-repo2/user/repo2.git"
