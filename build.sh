#!/bin/bash
c1541=/Applications/vice-gtk3-3.5/bin/c1541
dasm test.asm -otest.prg
dasm testsprite.asm -otestsprite.prg
dasm music.asm -omusic.prg
dasm plot.asm -oplot.prg
$c1541 -format diskname,id d64 `pwd`/test_build.d64 -attach `pwd`/test_build.d64 -write `pwd`/test.prg
$c1541 -attach `pwd`/test_build.d64 -write `pwd`/testsprite.prg
$c1541 -attach `pwd`/test_build.d64 -write `pwd`/music.prg
$c1541 -attach `pwd`/test_build.d64 -write `pwd`/plot.prg
