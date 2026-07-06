#!/usr/bin/env bash

set -eu

# dst=$(basename "$0" .sh).epub
dst=.

doc_title="$(head -n1 readme.md | sed 's/^#\s*//')"

if false; then
  scan_resolution=600
else
  source 030-measure-page-size.txt
fi

if [ "$dst" != "." ] && [ -e "$dst" ]; then
  echo "error: output exists: $dst"
  exit 1
fi

# downscale to 300 dpi
scale=$(python -c "print(300 / $scan_resolution)")

args=(
  hocr-to-epub-fxl
  --output "$dst"
)
if [ "$dst" = "." ]; then
  args+=(
    --output-unpacked
  )
fi

doc_modified=$(
  {
    git show -s --format=%cI HEAD
    stat -c%y 090-ocr | sed -E 's/^([0-9-]+) ([0-9:]+)\.[0-9]+ ([+-][0-9]{2})([0-9]{2})$/\1T\2\3:\4/'
  } |
  LANG=C sort |
  tail -n1
)

args+=(
  --scale "$scale"
  --image-format avif
  --text-format html
  --doc-modified "$doc_modified"
  --color-image-pages 305,306
  --doc-title "Die digitale Weltkontrolle"
  --doc-subtitle "The Digital World Brain – Die UN-Agenda, der Zukunftspakt und die Abgabe unserer Freiheit"
  --doc-description "Was wäre, wenn die größte Machtverschiebung unserer Zeit längst beschlossen ist?

Der schwedische Wissenschaftler Dr. Jacob Nordangård zeigt,
dass sich hinter Begriffen wie „Nachhaltigkeit“, „Gleichheit“ und „Gerechtigkeit“ ein Etikettenschwindel verbirgt,
der auf eine düstere Agenda abzielt.

Eine Agenda, in der Überwachung und digitale Identitäten zu Instrumenten umfassender Kontrolle werden.

Im Zentrum steht „Our Common Agenda“, das Reformprojekt der Agenda 2030. Es ebnet den Weg für eine neue Form globaler Steuerung,
in der internationale Organisationen, Finanzakteure und „Philanthropen“ beispiellose Machtbefugnisse erhalten –
und die Welt schleichend in eine Technokratie geführt wird.

Es geht nicht um Reformen. Es geht um Macht.
Und um die Frage, wer in Zukunft über unser Leben entscheidet."
  --doc-subject "Conspiracy"
  --doc-date 2026-05-05
  --doc-edition 1
  --doc-extent "304 pages"
  --doc-author "Jacob Nordangård"
  # --doc-introducer ""
  # --doc-contributor ""
  --doc-translator "Siddhartha Peghini Bailey"
  --doc-publisher "Corage Media"
  --doc-language de
  --doc-isbn 9789083525969
  --doc-cover-image 077-compress-jpeg/305.jpg
  --canonical-url-base https://milahu.github.io/jacob-nordangard-digitale-weltkontrolle-2026/
)

 printf '>'
for a in "${args[@]}" "$@"; do printf ' %q' "$a"; done
echo ' *-ocr/*.hocr'

"${args[@]}" "$@" *-ocr/*.hocr

if [ "$dst" = "." ]; then
  echo "done ./index.xhtml"
  exit
fi

echo "done $dst"

rm -rf $dst.unzip
mkdir $dst.unzip
cd $dst.unzip
unzip -q ../$dst
cd ..

echo "done $dst.unzip/index.html"
