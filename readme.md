# BASE32 class

This class is for encoding/decoding data for [Base32](https://en.wikipedia.org/wiki/Base32).

## Supported algorithm
- alphabet
- hex
- geohash

## Examples
```
SET PROCEDURE TO base.prg ADDITIVE
LOCAL m.loBASE32, m.lcIn, m.lcOut
m.loBASE32=CREATEOBJECT("_BASE32") 
m.lcIn="Hello world"

m.lcOut=m.loBASE32.TOALPHABET(m.lcIn)
?
?m.lcIn
?m.lcOut
?m.loBASE32.FROMALPHABET(m.lcOut)

m.lcOut=m.loBASE32.TOHEX(m.lcIn)
?
?m.lcIn
?m.lcOut
?m.loBASE32.FROMHEX(m.lcOut)

m.lcOut=m.loBASE32.TOGEOHASH(m.lcIn)
?
?m.lcIn
?m.lcOut
?m.loBASE32.FROMGEOHASH(m.lcOut)
``` 

