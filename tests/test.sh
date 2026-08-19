set -euv -o pipefail

mkdir -p output

cd input
../../bin/make-subset-font-css doc.nmm fonts.css > ../output/subset_fonts.css
cd -

nmm-ocaml html-of-nmm --internal-css input/fonts.css --internal-css input/style.css input/doc.nmm > output/doc.html

nmm-ocaml html-of-nmm --internal-css output/subset_fonts.css --internal-css input/style.css input/doc.nmm > output/doc_standalone.html

diff expected_output/subset_fonts.css output/subset_fonts.css > /dev/null

