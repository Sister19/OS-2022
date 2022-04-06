#!/bin/bash
# Asumsi SSH Key sudah terkonfigurasi dengan benar
ROOTGH=git@github.com:Sister19/

PREFIX="tugas-besar-os-"
# VERSION="v.1.0.0"
VERSION="v.2.0.0"
# VERSION="v.3.0.0"
SUFFIX=".git"

# NAMES=("ExMessageTheory" "X_X" "OSkadon" "hobi-bolOS" "ngOS" "GachaOS" "nyOSahin" "Semangka" "NewOSocialCredit" "Tub0s" "FujOShi" "pekOS" "SSOLoginError" "amongOS" "OShi" "OSengCumi" "mengkeOS" "TukangBikinOS" "OZ")
# NAMES=("keOS-Gaming" "baltOS" "GWS_OS" "yukBisa" "minaOS" "osOS" "OStrich" "bjirtOS" "TubesOSis" "delTa" "kurang-keOS-bund" "uSUSbuntu" "dolphinOS" "apelOS" "bansOS" "ClownOS" "chaOS" "saOS" "polOS")
NAMES=("sOSis" "thanOS" "MayanOS" "AiOS" "UpayaBUNTU" "yOSh" "yOSalek" "SOS" "OStaga" "Rest-In-Keos" "keOS" "MakeOS" "OSama" "CTOS" "lOSsantOS" "chocolatOS" "mampOS" "manggaOS")

for i in ${!NAMES[@]}
do
  git clone -b $VERSION $ROOTGH$PREFIX${NAMES[$i]}$SUFFIX
done
