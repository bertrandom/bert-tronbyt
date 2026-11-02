# bert-tronbyt

Custom apps for my [Tronbyt](https://github.com/tronbyt/server) server. Each app lives in
`apps/<app_id>/<app_id>.star`.

## Apps

### vestaboard

Draws a Vestaboard pattern (6 rows × 21 bits) on the 64×32 display.

The grid comes from the `message_body` config value: a JSON-encoded 6×21 array of Vestaboard
character codes. Codes 63–68 are the colors, 69 and 71 are white, 70 is black, and anything else
is drawn as an empty bit. With no `message_body` it draws a blank board.

It doesn't fetch anything itself. [vestaboard-pattern-server](https://github.com/bertrandom/vestaboard-pattern-server)
sets `message_body` on the installation and pushes the app with the same config whenever the
selected pattern changes.

To render it locally with a config file containing `{"message_body": "[[...], ...]"}`:

```
pixlet render apps/vestaboard/vestaboard.star -c config.json -o vestaboard.webp
```
