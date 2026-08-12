# shedos-theme-catppuccin

The four Catppuccin Mocha palettes ShedOS ships, and nothing else. A theme is
a data package: palette TOMLs under `/usr/share/shedos/themes/palettes/`,
where pacman keeps them, plus one metadata file naming the GTK theme each was
drawn against.

`shedos-theme-engine` is what reads them. It looks in
`/etc/shedos/themes/palettes/` first, so a file dropped there overrides one of
these by name without being overwritten on the next upgrade — which is what
happened while these lived under `/etc` themselves.

The metadata file is named for this package because several theme packages
share `/usr/share/shedos/themes/metadata/` and only one of them can own a
given file name.

`test/palettes` asks whether each palette parses, whether every colour is
`#rrggbb`, whether the accent names colours it defines, and whether the
metadata names exactly the palettes shipped beside it. The 26-token set a
palette must carry belongs to the engine and is asked there.
