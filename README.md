# Musicle

Musicle is a game-like thing made in Ocaml. The program plays 5 seconds of any song saved on your device and you have to guess it!

(Technically it's probably going to be closer to Anki then Wordle but whatever)

## Usage

Musicle is a CLI app. To make it work, you need to initially set the music directory using a command like this one:

```
musicle set_music_dir <directory with music>
```

Then you can play it either for one round using:

```
musicle once
```

Or as long as you want using:

```
musicle many
```
