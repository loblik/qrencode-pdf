# qrencode-pdf
Generate simple PDF with Wi-Fi QR code

## Motivation
This script generates a simple PDF document with Wi-Fi credentials and QR code. It uses only qrencode, sh and common shell utilities. The idea is to use it in resource limited environments, like OpenWRT routers. Where it can be used to automatically renew the password for guest network.

## Usage
Script can be used like this.
```
qrencode-pdf.sh -v 13 -p secterPassword -s MyWiFiNetwork > /tmp/wifi_credentials.pdf
```

## Tips

* use crontab to regenerate Wi-Fi password and PDF
* most printers nowadays support PDF as a printer language, so generated page can be automatically sent to it with netcat or something
* hookup OpenWRT router button (WPS or other) to script to regenerate or reprint the credentials
