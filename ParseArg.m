(*
Copyright © 2014 Eon S. Jeon <esjeon@hyunmu.am>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*)

BeginPackage["ParseArg`"]

ParseArg[args_,pats_]:=
  Block[{ CurrentFlag, CurrentToken, ReadString, ReadNumber, ReadChar},
  Module[{ as, cs, flg, tok },
    CurrentFlag[] := flg;

    CurrentToken[] := tok;

    ReadChar[]:=
      If[(Length[cs] > 1),
        cs = Rest[cs]; First[cs],
        Throw["Expect more characters after " <> First[as], Symbol["EParseArg"]]
      ];

    ReadNumber[]:=
      If[(Length[cs] > 1),
        With[{ s = TakeWhile[Rest[cs], StringMatchQ[#, DigitCharacter]&] },
          If[(Length[s] > 0),
            cs = Drop[cs, Length[s]]; FromDigits[StringJoin[s]],
            Throw["Require a number after " <> First[as], Symbol["EParseArg"]]
        ]],
        If[(Length[as] > 1),
          as = Rest[as];
          If[(StringMatchQ[First[as], NumberString]),
            FromDigits[First[as]],
            Throw["Expected a number, but got "<>First[as],Symbol["EParseArg"]]
          ],
          Throw["Require a number after "<>First[as],Symbol["EParseArg"]]
        ]
      ];

    ReadString[]:=
      If[(Length[cs] > 1),
        With[{ str = StringJoin[Rest[cs]] },
          cs = {Last[cs]}; str
        ],
        If[(Length[as] > 1),
          as = Rest[as]; First[as],
          Throw["Expect a token after " <> First[as], Symbol["EParseArg"]]
        ]
      ];

    For[as = args, Length[as] > 0, as = Rest[as],
      tok = First[as];
      flg = "";
      cs = Characters[First[as]];
      If[(First[cs] != "-"),
        "default" /. pats;,
        For[cs = Rest[cs], Length[cs] > 0, cs = Rest[cs],
          flg = First[cs];
          flg /. pats;
        ]
      ]
    ]
  ]];

EndPackage[]
