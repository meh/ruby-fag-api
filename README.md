fag - the Ruby API
==================

This gem wraps the calls to fag in an usable way, it also includes a functional CLI to fag.

CLI
---
If you want to use the CLI you also have to install the `colorb` and `stty` gems.

Sample config file `~/.fagrc`

```yaml
url: http://this.is.the.host:port

# this is needed only if you're registered, you can register with `fag --register`
name: yourname
password: thisisapassword

colors:
  separator:    black.bold
  registered:   blue.bold
  unregistered: blue
  tag:          red
  id:           white.bold
  quote:        green
  content:
  title:
```

### Themes

"matrix" like theme:

```yaml
colors:
  separator:    black.bold
  registered:   green.underline
  unregistered: green
  tag:          green
  id:           green
  quote:
  content:
  title:
```
