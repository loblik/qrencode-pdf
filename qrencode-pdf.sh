#!/bin/sh

# qrencode-pdf - Generate simple PDF with Wi-Fi QR code
# Copyright (C) 2026  Pavel Löbl
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; If not, see <http://www.gnu.org/licenses/>.

qr_x=100
qr_y=200
qr_bit_size=4

# A4 dimensions at 72 DPI
# change this for Letter or other
height=842
width=585

number=30

generate_qr_stream() {
  qr=$(qrencode -m0 -t ascii "WIFI:T:WPA;S:$ssid;P:$password;;")

  timestamp=$(date "+$version (%d.%m.%Y)")

  echo BT
  echo /F1 35 Tf
  echo 95 $((height-150)) Td
  echo "(Guest Wi-Fi Access) Tj"
  echo ET

  echo BT
  echo /F1 10 Tf
  echo $qr_x $((qr_y-30)) Td
  echo "(    SSID: $ssid) Tj"
  echo ET

  echo BT
  echo /F1 10 Tf
  echo $qr_x $((qr_y-42)) Td
  echo "(Password: $password) Tj"
  echo ET

  echo BT
  echo /F1 10 Tf
  echo $((width-160)) 60 Td
  echo "($timestamp) Tj"
  echo ET

  echo 0 0 0 rg

  l=0
  echo "$qr" | while IFS='\n' read line; do
    i=0
    echo "$line" | grep -o . | while read char; do
      if [ $((i % 2)) -eq 0 ]; then
        if [ "$char" = "#" ];then
          echo $((qr_x + qr_bit_size*(i>>1))) $((qr_y + qr_bit_size*l)) $qr_bit_size $qr_bit_size "re"
        fi
      fi
      i=$((i+1))
    done
    l=$((l+1))
  done

  echo f

}

generate_qr_obj() {

  stream=$(generate_qr_stream)
  stream_size=${#stream}

  echo "5 0 obj"
  echo

  echo "<<"
  echo "/Length ${#stream}"
  echo ">>"
  echo stream

  echo "$stream"


  echo "endstream "
  echo endobj
}


usage() {
    cat <<EOF >&2
Usage: $0 -v VERSION -p PASSWORD -s SSID

Options:
  -v VERSION   credentials revision
  -p PASSWORD  Wi-Fi password
  -s SSID      Wi-Fi SSID
EOF
    exit 1
}

while getopts "v:p:s:" opt; do
    case "$opt" in
        v) version=$OPTARG ;;
        p) password=$OPTARG ;;
        s) ssid=$OPTARG ;;
        *) usage ;;
    esac
done

shift $((OPTIND - 1))

[ -n "$version" ]  || usage
[ -n "$password" ] || usage
[ -n "$ssid" ]     || usage

cat<<PDF_HEAD
%PDF-1.4
%FILL
1 0 obj

<<
/Type /Catalog
/Pages 2 0 R
>>
endobj

2 0 obj

<<
/Kids [3 0 R]
/Type /Pages
/Count 1
>>
endobj

3 0 obj

<<
/Contents 5 0 R
/Type /Page
/Resources 
<<
/Font 
<<
/F1 4 0 R
>>
>>
/Parent 2 0 R
/MediaBox [0 0 $width $height]
>>
endobj

4 0 obj

<<
/Subtype /Type1
/Type /Font
/BaseFont /Courier
>>
endobj

PDF_HEAD

generate_qr_obj

cat<<PDF_TAIL
xref
0 6
0000000000 65535 f 
0000000015 00000 n 
0000000066 00000 n 
0000000125 00000 n 
0000000255 00000 n 
0000000325 00000 n 
trailer

<<
/Root 1 0 R
/Size 6
>>
startxref
$((stream_size+378))
%%EOF
PDF_TAIL
