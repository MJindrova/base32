CLEAR

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



DEFINE CLASS _BASE32 AS CUSTOM
   Name="_BASE32"
   DIMENSION aCODE(16)
   aCODE(01)='0000'
   aCODE(02)='0001'
   aCODE(03)='0010'
   aCODE(04)='0011'
   aCODE(05)='0100'
   aCODE(06)='0101'
   aCODE(07)='0110'
   aCODE(08)='0111'
   aCODE(09)='1000'
   aCODE(10)='1001'
   aCODE(11)='1010'
   aCODE(12)='1011'
   aCODE(13)='1100'
   aCODE(14)='1101'
   aCODE(15)='1110'
   aCODE(16)='1111'

   DIMENSION aCODE32(32)
   aCODE32(01)='00000'
   aCODE32(02)='00001'
   aCODE32(03)='00010'
   aCODE32(04)='00011'
   aCODE32(05)='00100'
   aCODE32(06)='00101'
   aCODE32(07)='00110'
   aCODE32(08)='00111'
   aCODE32(09)='01000'
   aCODE32(10)='01001'
   aCODE32(11)='01010'
   aCODE32(12)='01011'
   aCODE32(13)='01100'
   aCODE32(14)='01101'
   aCODE32(15)='01110'
   aCODE32(16)='01111'
   aCODE32(17)='10000'
   aCODE32(18)='10001'
   aCODE32(19)='10010'
   aCODE32(20)='10011'
   aCODE32(21)='10100'
   aCODE32(22)='10101'
   aCODE32(23)='10110'
   aCODE32(24)='10111'
   aCODE32(25)='11000'
   aCODE32(26)='11001'
   aCODE32(27)='11010'
   aCODE32(28)='11011'
   aCODE32(29)='11100'
   aCODE32(30)='11101'
   aCODE32(31)='11110'
   aCODE32(32)='11111'


   PROCEDURE CharToBin
      *
      * _BASE32::CharToBin
      *
      LPARAMETERS m.lcChar
      RETURN This.aCode(BITRSHIFT(ASC(m.lcChar),4)+1)+This.aCode(BITAND(ASC(m.lcChar),0x0F)+1)
   ENDPROC


   PROCEDURE ByteToBin
      *
      * _BASE32::ByteToBin
      *
      LPARAMETERS m.liChar
      RETURN This.aCode(BITRSHIFT(m.liChar,4)+1)+This.aCode(BITAND(m.liChar,0x0F)+1)
   ENDPROC


   PROCEDURE StringToBin
      *
      * _BASE32::StringToBin
      *
      LPARAMETERS m.lcText
      LOCAL m.lii, m.liChar, m.lcBINDATA
      m.lcBINDATA=""
      FOR m.lii=1 TO LEN(m.lcText)
          m.liChar=ASC(SUBSTR(m.lcText, m.lii,1))
          m.lcBINDATA=m.lcBINDATA+This.aCode(BITRSHIFT(m.liChar,4)+1)+This.aCode(BITAND(m.liChar,0x0F)+1)
      NEXT
      RETURN m.lcBINDATA
   ENDPROC


   PROCEDURE BinToInt && 31-00
      *
      * _BASE32::BinToInt
      *
      LPARAMETERS m.lcBIN
      LOCAL m.lii, m.liRes
      m.liRes=0
      FOR m.lii=1 TO LEN(m.lcBIN)
          m.liRes=m.liRes+IIF(SUBSTR(m.lcBIN, m.lii,1)="1", BITSET(0, LEN(m.lcBIN)-m.lii), 0)
      NEXT
      RETURN m.liRes 
   ENDPROC


   PROCEDURE C5BToInt
      *
      * _BASE32::C5BToInt
      *
      LPARAMETERS m.lcBIN
      RETURN IIF(LEFT(m.lcBIN, 1)="1",16,0)+ASCAN(This.aCode,RIGHT(m.lcBIN,4))-1
   ENDPROC


   PROCEDURE C8BToInt
      *
      * _BASE32::C8ToInt
      *
      LPARAMETERS m.lcBIN
      RETURN (ASCAN(This.aCode,LEFT(m.lcBIN,4))-1)*16+ASCAN(This.aCode,RIGHT(m.lcBIN,4))-1
   ENDPROC

   *****************
   * Zero version
   *****************
   * was very slow

   *****************
   * First version
   *****************
   PROCEDURE ToALPHABET_V1
      *
      * _BASE32::ToALPHABET_V1
      *
      LPARAMETERS m.lcText
      *https://emn178.github.io/online-tools/base32_encode.html

      LOCAL m.lcBINDATA, m.lcHASHEDDATA, m.lii, m.liChar, m.liLen
      STORE "" TO m.lcHASHEDDATA, m.lcBINDATA
      m.liLen=LEN(m.lcText)
      FOR m.lii=1 TO m.liLen
          m.liChar=ASC(SUBSTR(m.lcText, m.lii,1))
          m.lcBINDATA=m.lcBINDATA+This.aCode(BITRSHIFT(m.liChar,4)+1)+This.aCode(BITAND(m.liChar,0x0F)+1)

          m.liChar=This.C5BToInt(LEFT(m.lcBINDATA, 5))
          m.lcHASHEDDATA=m.lcHASHEDDATA+CHR(IIF(m.liChar>25, 24, 65)+m.liChar)
          m.lcBINDATA=SUBSTR(m.lcBINDATA,6)
      NEXT
      m.liLen=m.liLen*8
      IF m.liLen%5>0
         m.lcBINDATA=m.lcBINDATA+REPLICATE("0", 5-m.liLen%5)
      ENDIF
      FOR m.lii=1 TO LEN(m.lcBINDATA) STEP 5
          m.liChar=This.C5BToInt(SUBSTR(m.lcBINDATA, m.lii, 5))
          m.lcHASHEDDATA=m.lcHASHEDDATA+CHR(IIF(m.liChar>25, 24, 65)+m.liChar)
      NEXT

      IF LEN(m.lcHASHEDDATA)%8>0
         m.lcHASHEDDATA=m.lcHASHEDDATA+REPLICATE("=", 8-LEN(m.lcHASHEDDATA)%8)
      ENDIF
      RETURN m.lcHASHEDDATA
   ENDPROC


   PROCEDURE ToHEX_V1
      *
      * _BASE32::ToHEX_V1
      *
      LPARAMETERS m.lcText

      *https://simplycalc.com/base32hex-decode.php
      *http://tomeko.net/online_tools/base32hex.php?lang=en
      
      LOCAL m.lcBINDATA, m.lcHASHEDDATA, m.lii, m.liChar, m.liLen
      STORE "" TO m.lcHASHEDDATA, m.lcBINDATA
      m.liLen=LEN(m.lcText)
      FOR m.lii=1 TO m.liLen
          m.liChar=ASC(SUBSTR(m.lcText, m.lii,1))
          m.lcBINDATA=m.lcBINDATA+This.aCode(BITRSHIFT(m.liChar,4)+1)+This.aCode(BITAND(m.liChar,0x0F)+1)

          m.liChar=This.C5BToInt(LEFT(m.lcBINDATA, 5))
          m.lcHASHEDDATA=m.lcHASHEDDATA+CHR(IIF(m.liChar<10, 48, 55)+m.liChar)
          m.lcBINDATA=SUBSTR(m.lcBINDATA,6)
      NEXT
      m.liLen=m.liLen*8
      IF m.liLen%5>0
         m.lcBINDATA=m.lcBINDATA+REPLICATE("0", 5-m.liLen%5)
      ENDIF
      FOR m.lii=1 TO LEN(m.lcBINDATA) STEP 5
          m.liChar=This.C5BToInt(SUBSTR(m.lcBINDATA, m.lii, 5))
          m.lcHASHEDDATA=m.lcHASHEDDATA+CHR(IIF(m.liChar<10, 48, 55)+m.liChar)
      NEXT

      IF LEN(m.lcHASHEDDATA)%8>0
         m.lcHASHEDDATA=m.lcHASHEDDATA+REPLICATE("=", 8-LEN(m.lcHASHEDDATA)%8)
      ENDIF
      RETURN m.lcHASHEDDATA
   ENDPROC


   PROCEDURE FromALPHABET_V1
      *
      * _BASE32::FromALPHABET_V1
      *
      LPARAMETERS m.lcHASHEDDATA

      LOCAL m.lcBINDATA, m.lii, m.liChar, m.liLen, m.lcText
      STORE "" TO m.lcText, m.lcBINDATA
      
      m.liLen=AT("=",m.lcHASHEDDATA)
      m.liLen=IIF(m.liLen=0, LEN(m.lcHASHEDDATA), m.liLen-1)

      FOR m.lii=1 TO m.liLen
          m.liChar=ASC(SUBSTR(m.lcHASHEDDATA, m.lii,1))
          m.lcBINDATA=m.lcBINDATA+This.aCode32(m.liChar-IIF(m.liChar>=65, 65, 24)+1)
          
          IF LEN(m.lcBINDATA)>7
             m.liChar=This.C8BToInt(LEFT(m.lcBINDATA, 8))
             m.lcText=m.lcText+CHR(m.liChar)
             m.lcBINDATA=SUBSTR(m.lcBINDATA,9)
          ENDIF
      NEXT
      RETURN m.lcText
   ENDPROC


   PROCEDURE FromHEX_V1
      *
      * _BASE32::FromHEX_V1
      *
      LPARAMETERS m.lcHASHEDDATA

      LOCAL m.lcBINDATA, m.lii, m.liChar, m.liLen, m.lcText
      STORE "" TO m.lcText, m.lcBINDATA
      
      m.liLen=AT("=",m.lcHASHEDDATA)
      m.liLen=IIF(m.liLen=0, LEN(m.lcHASHEDDATA), m.liLen-1)

      FOR m.lii=1 TO m.liLen
          m.liChar=ASC(SUBSTR(m.lcHASHEDDATA, m.lii,1))
          m.lcBINDATA=m.lcBINDATA+This.aCode32(m.liChar-IIF(m.liChar>=65, 55, 48)+1)

          IF LEN(m.lcBINDATA)>7
             m.liChar=This.C8BToInt(LEFT(m.lcBINDATA, 8))
             m.lcText=m.lcText+CHR(m.liChar)
             m.lcBINDATA=SUBSTR(m.lcBINDATA,9)
          ENDIF
      NEXT
      RETURN m.lcText
   ENDPROC


   *****************
   * Second version
   *****************
   PROCEDURE Encode32Block
      *
      * _BASE32::Encode32Block
      *
      LPARAMETERS m.lcB4, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58
      LOCAL m.lii, m.liLen
      
      *       |       |       |       |       |
      *       1       2       3       4       5
      *0123456701234567012345670123456701234567
      *    |    |    |    |    |    |    |    |
      *    1    2    3    4    5    6    7    8
      *0123401234012340123401234012340123401234
      
      m.liLen=LEN(m.lcB4)
      m.liBINDATA=BITLSHIFT(ASC(SUBSTR(m.lcB4,1,1)),16) + BITLSHIFT(ASC(SUBSTR(m.lcB4,2,1)),8) + BITAND(ASC(SUBSTR(m.lcB4,3,1)), 0xF0)
      m.liC51=IIF(m.liLen<1, .NULL., BITRSHIFT(BITAND(m.liBINDATA, 0xF80000), 19))
      m.liC52=IIF(m.liLen<1, .NULL., BITRSHIFT(BITAND(m.liBINDATA, 0x07C000), 14))
      m.liC53=IIF(m.liLen<2, .NULL., BITRSHIFT(BITAND(m.liBINDATA, 0x003E00), 09))
      m.liC54=IIF(m.liLen<2, .NULL., BITRSHIFT(BITAND(m.liBINDATA, 0x0001F0), 04))

      m.liBINDATA=BITLSHIFT(BITLSHIFT(BITAND(ASC(SUBSTR(m.lcB4,3,1)), 0x0F),16) + BITLSHIFT(ASC(SUBSTR(m.lcB4,4,1)),8)+ASC(SUBSTR(m.lcB4,5,1)),4)
      m.liC55=IIF(m.liLen<3, .NULL., BITRSHIFT(BITAND(m.liBINDATA, 0xF80000), 19))
      m.liC56=IIF(m.liLen<4, .NULL., BITRSHIFT(BITAND(m.liBINDATA, 0x07C000), 14))
      m.liC57=IIF(m.liLen<4, .NULL., BITRSHIFT(BITAND(m.liBINDATA, 0x003E00), 09))
      m.liC58=IIF(m.liLen<5, .NULL., BITRSHIFT(BITAND(m.liBINDATA, 0x0001F0), 04))
   ENDPROC
   
   
   PROCEDURE ToALPHABET && ALPHABET on steroids
      *
      * _BASE32::ToALPHABET
      *
      LPARAMETERS m.lcText
      *https://emn178.github.io/online-tools/base32_encode.html

      LOCAL m.lcHASHEDDATA, m.lii, m.liLen, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58

      STORE "" TO m.lcHASHEDDATA
      m.liLen=LEN(m.lcText)
      FOR m.lii=1 TO m.liLen STEP 5
          This.Encode32Block(SUBSTR(m.lcText,m.lii,5), @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          m.lcHASHEDDATA=m.lcHASHEDDATA+;
                         IIF(ISNULL(m.liC51),"",CHR(IIF(m.liC51>25, 24, 65)+m.liC51))+IIF(ISNULL(m.liC52),"",CHR(IIF(m.liC52>25, 24, 65)+m.liC52))+;
                         IIF(ISNULL(m.liC53),"",CHR(IIF(m.liC53>25, 24, 65)+m.liC53))+IIF(ISNULL(m.liC54),"",CHR(IIF(m.liC54>25, 24, 65)+m.liC54))+;
                         IIF(ISNULL(m.liC55),"",CHR(IIF(m.liC55>25, 24, 65)+m.liC55))+IIF(ISNULL(m.liC56),"",CHR(IIF(m.liC56>25, 24, 65)+m.liC56))+;
                         IIF(ISNULL(m.liC57),"",CHR(IIF(m.liC57>25, 24, 65)+m.liC57))+IIF(ISNULL(m.liC58),"",CHR(IIF(m.liC58>25, 24, 65)+m.liC58))
      NEXT
      
      IF LEN(m.lcHASHEDDATA)%8>0
         m.lcHASHEDDATA=m.lcHASHEDDATA+REPLICATE("=", 8-LEN(m.lcHASHEDDATA)%8)
      ENDIF
      RETURN m.lcHASHEDDATA
   ENDPROC


   PROCEDURE ToHEX && HEX on steroids
      *
      * _BASE32::ToHEX
      *
      LPARAMETERS m.lcText

      LOCAL m.lcHASHEDDATA, m.lii, m.liLen, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58

      STORE "" TO m.lcHASHEDDATA
      m.liLen=LEN(m.lcText)
      FOR m.lii=1 TO m.liLen STEP 5
          This.Encode32Block(SUBSTR(m.lcText,m.lii,5), @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          m.lcHASHEDDATA=m.lcHASHEDDATA+; 
                         IIF(ISNULL(m.liC51),"",CHR(IIF(m.liC51<10, 48, 55)+m.liC51))+IIF(ISNULL(m.liC52),"",CHR(IIF(m.liC52<10, 48, 55)+m.liC52))+;
                         IIF(ISNULL(m.liC53),"",CHR(IIF(m.liC53<10, 48, 55)+m.liC53))+IIF(ISNULL(m.liC54),"",CHR(IIF(m.liC54<10, 48, 55)+m.liC54))+;
                         IIF(ISNULL(m.liC55),"",CHR(IIF(m.liC55<10, 48, 55)+m.liC55))+IIF(ISNULL(m.liC56),"",CHR(IIF(m.liC56<10, 48, 55)+m.liC56))+;
                         IIF(ISNULL(m.liC57),"",CHR(IIF(m.liC57<10, 48, 55)+m.liC57))+IIF(ISNULL(m.liC58),"",CHR(IIF(m.liC58<10, 48, 55)+m.liC58))
      NEXT
      
      IF LEN(m.lcHASHEDDATA)%8>0
         m.lcHASHEDDATA=m.lcHASHEDDATA+REPLICATE("=", 8-LEN(m.lcHASHEDDATA)%8)
      ENDIF
      RETURN m.lcHASHEDDATA
   ENDPROC


   PROCEDURE ToGEOHASH 
      *
      * _BASE32::GEOHASH
      *
      LPARAMETERS m.lcText

      LOCAL m.lcHASHEDDATA, m.lii, m.liLen, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58

      STORE "" TO m.lcHASHEDDATA
      m.liLen=LEN(m.lcText)
      FOR m.lii=1 TO m.liLen STEP 5
          This.Encode32Block(SUBSTR(m.lcText,m.lii,5), @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          m.lcHASHEDDATA=m.lcHASHEDDATA+; 
                         IIF(ISNULL(m.liC51),"",CHR(IIF(m.liC51<10, 48, 88)+m.liC51))+IIF(ISNULL(m.liC52),"",CHR(IIF(m.liC52<10, 48, 88)+m.liC52))+;
                         IIF(ISNULL(m.liC53),"",CHR(IIF(m.liC53<10, 48, 88)+m.liC53))+IIF(ISNULL(m.liC54),"",CHR(IIF(m.liC54<10, 48, 88)+m.liC54))+;
                         IIF(ISNULL(m.liC55),"",CHR(IIF(m.liC55<10, 48, 88)+m.liC55))+IIF(ISNULL(m.liC56),"",CHR(IIF(m.liC56<10, 48, 88)+m.liC56))+;
                         IIF(ISNULL(m.liC57),"",CHR(IIF(m.liC57<10, 48, 88)+m.liC57))+IIF(ISNULL(m.liC58),"",CHR(IIF(m.liC58<10, 48, 88)+m.liC58))
      NEXT
      
      IF LEN(m.lcHASHEDDATA)%8>0
         m.lcHASHEDDATA=m.lcHASHEDDATA+REPLICATE("=", 8-LEN(m.lcHASHEDDATA)%8)
      ENDIF
      RETURN m.lcHASHEDDATA
   ENDPROC


   PROCEDURE Decode32Block
      *
      * _BASE32::Decode32Block
      *
      LPARAMETERS m.lcB5, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58
      
      *       |       |       |       |       |
      *       1       2       3       4       5
      *0123456701234567012345670123456701234567
      *    |    |    |    |    |    |    |    |
      *    1    2    3    4    5    6    7    8
      *0123401234012340123401234012340123401234

      m.lcB5=IIF(m.liC51<0 AND m.liC52<0, "", CHR(BITLSHIFT(MAX(m.liC51, 0), 3)+BITRSHIFT(MAX(m.liC52, 0), 2)))+;
             IIF(m.liC52<0 AND m.liC53<0 AND m.liC54<0, "", CHR(BITLSHIFT(BITAND(MAX(m.liC52, 0), 0x03), 6)+BITLSHIFT(MAX(m.liC53, 0), 1)+BITRSHIFT(MAX(m.liC54, 0), 4)))+;
             IIF(m.liC54<=0 AND m.liC55<0, "", CHR(BITLSHIFT(BITAND(MAX(m.liC54, 0), 0x0F), 4)+BITRSHIFT(MAX(m.liC55, 0), 1)))+;
             IIF(m.liC55<=0 AND m.liC56<0 AND m.liC57<0, "", CHR(BITLSHIFT(BITAND(MAX(m.liC55, 0), 0x01), 7)+BITLSHIFT(MAX(m.liC56, 0), 2)+BITRSHIFT(MAX(m.liC57, 0), 3)))+;
             IIF(m.liC57<=0 AND m.liC58<0, "", CHR(BITLSHIFT(BITAND(MAX(m.liC57, 0), 0x07), 5)+MAX(m.liC58, 0)))
   ENDPROC



   PROCEDURE DecodeALPHABlock
      *
      * _BASE32::DecodeALPHABlock
      *
      LPARAMETERS m.lcB8, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58
      
      m.liC51=ASC(SUBSTR(m.lcB8, 1, 1))
      m.liC52=ASC(SUBSTR(m.lcB8, 2, 1))
      m.liC53=ASC(SUBSTR(m.lcB8, 3, 1))
      m.liC54=ASC(SUBSTR(m.lcB8, 4, 1))
      m.liC55=ASC(SUBSTR(m.lcB8, 5, 1))
      m.liC56=ASC(SUBSTR(m.lcB8, 6, 1))
      m.liC57=ASC(SUBSTR(m.lcB8, 7, 1))
      m.liC58=ASC(SUBSTR(m.lcB8, 8, 1))
      
      m.liC51=m.liC51-IIF(m.liC51>=65, 65, 24)
      m.liC52=m.liC52-IIF(m.liC52>=65, 65, 24)
      m.liC53=m.liC53-IIF(m.liC53>=65, 65, 24)
      m.liC54=m.liC54-IIF(m.liC54>=65, 65, 24)
      m.liC55=m.liC55-IIF(m.liC55>=65, 65, 24)
      m.liC56=m.liC56-IIF(m.liC56>=65, 65, 24)
      m.liC57=m.liC57-IIF(m.liC57>=65, 65, 24)
      m.liC58=m.liC58-IIF(m.liC58>=65, 65, 24)
   ENDPROC


   PROCEDURE FromALPHABET
      *
      * _BASE32::FromALPHABET
      *
      LPARAMETERS m.lcHASHEDDATA

      LOCAL m.lcBINDATA, m.lii, m.liLen, m.lcText, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58
      STORE "" TO m.lcText

      m.liLen=AT("=",m.lcHASHEDDATA)
      m.liLen=IIF(m.liLen=0, LEN(m.lcHASHEDDATA), m.liLen-1)
      m.lcHASHEDDATA=LEFT(m.lcHASHEDDATA, m.liLen)

      FOR m.lii=1 TO m.liLen STEP 8
          m.lcBINDATA=SUBSTR(m.lcHASHEDDATA, m.lii, 8)
          This.DecodeALPHABlock(@m.lcBINDATA, @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          This.Decode32Block(@m.lcBINDATA, @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          m.lcText=m.lcText+m.lcBINDATA
      NEXT
      RETURN m.lcText
   ENDPROC


   PROCEDURE DecodeHEXBlock
      *
      * _BASE32::DecodeHEXBlock
      *
      LPARAMETERS m.lcB8, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58
      
      m.liC51=ASC(SUBSTR(m.lcB8, 1, 1))
      m.liC52=ASC(SUBSTR(m.lcB8, 2, 1))
      m.liC53=ASC(SUBSTR(m.lcB8, 3, 1))
      m.liC54=ASC(SUBSTR(m.lcB8, 4, 1))
      m.liC55=ASC(SUBSTR(m.lcB8, 5, 1))
      m.liC56=ASC(SUBSTR(m.lcB8, 6, 1))
      m.liC57=ASC(SUBSTR(m.lcB8, 7, 1))
      m.liC58=ASC(SUBSTR(m.lcB8, 8, 1))
      
      m.liC51=m.liC51-IIF(m.liC51>=65, 55, 48)
      m.liC52=m.liC52-IIF(m.liC52>=65, 55, 48)
      m.liC53=m.liC53-IIF(m.liC53>=65, 55, 48)
      m.liC54=m.liC54-IIF(m.liC54>=65, 55, 48)
      m.liC55=m.liC55-IIF(m.liC55>=65, 55, 48)
      m.liC56=m.liC56-IIF(m.liC56>=65, 55, 48)
      m.liC57=m.liC57-IIF(m.liC57>=65, 55, 48)
      m.liC58=m.liC58-IIF(m.liC58>=65, 55, 48)
   ENDPROC


   PROCEDURE FromHEX
      *
      * _BASE32::FromHEX
      *
      LPARAMETERS m.lcHASHEDDATA

      LOCAL m.lcBINDATA, m.lii, m.liLen, m.lcText, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58
      STORE "" TO m.lcText

      m.liLen=AT("=",m.lcHASHEDDATA)
      m.liLen=IIF(m.liLen=0, LEN(m.lcHASHEDDATA), m.liLen-1)
      m.lcHASHEDDATA=LEFT(m.lcHASHEDDATA, m.liLen)

      FOR m.lii=1 TO m.liLen STEP 8
          m.lcBINDATA=SUBSTR(m.lcHASHEDDATA, m.lii, 8)
          This.DecodeHEXBlock(@m.lcBINDATA, @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          This.Decode32Block(@m.lcBINDATA, @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          m.lcText=m.lcText+m.lcBINDATA
      NEXT
      RETURN m.lcText
   ENDPROC


   PROCEDURE DecodeGEOHASHBlock
      *
      * _BASE32::DecodeGEOHASHBlock
      *
      LPARAMETERS m.lcB8, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58
      
      m.liC51=ASC(SUBSTR(m.lcB8, 1, 1))
      m.liC52=ASC(SUBSTR(m.lcB8, 2, 1))
      m.liC53=ASC(SUBSTR(m.lcB8, 3, 1))
      m.liC54=ASC(SUBSTR(m.lcB8, 4, 1))
      m.liC55=ASC(SUBSTR(m.lcB8, 5, 1))
      m.liC56=ASC(SUBSTR(m.lcB8, 6, 1))
      m.liC57=ASC(SUBSTR(m.lcB8, 7, 1))
      m.liC58=ASC(SUBSTR(m.lcB8, 8, 1))
      
      m.liC51=m.liC51-IIF(m.liC51>=98, 88, 48)
      m.liC52=m.liC52-IIF(m.liC52>=98, 88, 48)
      m.liC53=m.liC53-IIF(m.liC53>=98, 88, 48)
      m.liC54=m.liC54-IIF(m.liC54>=98, 88, 48)
      m.liC55=m.liC55-IIF(m.liC55>=98, 88, 48)
      m.liC56=m.liC56-IIF(m.liC56>=98, 88, 48)
      m.liC57=m.liC57-IIF(m.liC57>=98, 88, 48)
      m.liC58=m.liC58-IIF(m.liC58>=98, 88, 48)
   ENDPROC


   PROCEDURE FromGEOHASH
      *
      * _BASE32::FromGEOHASH
      *
      LPARAMETERS m.lcHASHEDDATA

      LOCAL m.lcBINDATA, m.lii, m.liLen, m.lcText, m.liC51, m.liC52, m.liC53, m.liC54, m.liC55, m.liC56, m.liC57, m.liC58
      STORE "" TO m.lcText

      m.liLen=AT("=",m.lcHASHEDDATA)
      m.liLen=IIF(m.liLen=0, LEN(m.lcHASHEDDATA), m.liLen-1)
      m.lcHASHEDDATA=LEFT(m.lcHASHEDDATA, m.liLen)

      FOR m.lii=1 TO m.liLen STEP 8
          m.lcBINDATA=SUBSTR(m.lcHASHEDDATA, m.lii, 8)
          This.DecodeGEOHASHBlock(@m.lcBINDATA, @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          This.Decode32Block(@m.lcBINDATA, @m.liC51, @m.liC52, @m.liC53, @m.liC54, @m.liC55, @m.liC56, @m.liC57, @m.liC58)
          m.lcText=m.lcText+m.lcBINDATA
      NEXT
      RETURN m.lcText
   ENDPROC

ENDDEFINE