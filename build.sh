mkdir build
cd ..
zip -r GogoLoot/build/GogoLoot GogoLoot -i '*.lua' '*.toc' '*.xml' 'GogoLoot/LICENSE' 'GogoLoot/README.md' -x 'GogoLoot/Libs/LibDeflate/tests/*'
open GogoLoot/build

