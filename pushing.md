To push to gitlab
```bash
git push origin main
```

To push to gitlab
```bash
git push github main
```

To push to both, there is an alias, `pushboth`
```bash
git pushboth
```
which does
```bash
git config --global alias.pushboth '!git push origin main && git push github main'
```bash

The same applies for pulling!