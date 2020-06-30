# Lambda3's Dotfiles

These are base dotfiles we use at Lambda3. We're using
[Dotbot](https://github.com/anishathalye/dotbot)
to automate it.

## Command line options

You can supply several options, run `.dotfiles/install --help` to see them.

## Installation

### Fork it

Fork it to your own user in Github, and make the changes you want. You will also
need to fork these repositories:

* https://github.com/Lambda3/bashscripts
* https://github.com/Lambda3/vimfiles

Then clone your repo with submodules (with ssh or HTTPS):

````bash
git clone --recurse-submodules git@github.com:<youruserongithub>/dotfiles.git $HOME/.dotfiles
````

Make your customizations, save, commit, push.

Then run the install script `~/.dotfiles/install`.

### Use it directly (not recommended)

*Note:* Some files and directories from the home directory will be removed. Check the
[install.conf.yaml](https://github.com/lambda3/dotfiles/blob/master/install.conf.yaml)
file, on the `shell` section to see which ones and make sure you are ok with it,
there will be no prompt.

* Clone this repo to ~/.dotfiles

You should use https:

````bash
git clone --recurse-submodules https://github.com/lambda3/dotfiles $HOME/.dotfiles
````

* Run the install script `~/.dotfiles/install`.

### Cleanning up before installing

Remove all directories that will be replaced by the submodules.

## Regarding fonts

You should use a Powerline enabled font, as some characters are Powerline
glyphs.

We recommend Cascasdia Code, download it from
[its release page](https://github.com/microsoft/cascadia-code/releases).
The font name you want is `Cascadia Code PL`.

Other Powerline fonts can be found at
[the Powerline fonts repository](https://github.com/powerline/fonts).

### Configuring the Windows Terminal

Add this to your config:

````json
{
  "profiles": {
    "defaults": {
      "fontFace": "Cascadia Code PL",
}
````

## Contributors

See them [here](https://github.com/Lambda3/dotfiles/graphs/contributors).

## License

Licensed under the Apache License, Version 2.0.
