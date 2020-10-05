#!/usr/bin/env wolframscript
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

Check[
  Needs["ParseArg`",
    FileNameJoin[{
      DirectoryName[FileInformation[$InputFileName, "AbsoluteFileName"]],
      "ParseArg.m"
    }]
  ],
  WriteString["stderr", "got an error while loading ParseArg.m. Exiting...\n"]; Exit[1]
]

(* configs *)
Begin["Config`"]
  input = ""
  output = ""
  keepOutputCell = False
End[]


die[msg_, n_] := (
  WriteString["stderr", msg, "\n"];
  Exit[n]
)

printUsage[] :=
  With[{name = FileNameTake[First[$ScriptCommandLine]]},
    WriteString["stdout",
      "Usage: " <> name <> " [-h] [-O] [-o output-file] input-file\n"
    ]
  ];

removeOutputCells[nb_] :=
  Replace[nb, HoldPattern[Cell[_,"Output",__]]   -> Sequence[], Infinity]

removeChangeTime[nb_] := (
  Replace[nb, HoldPattern[CellChangeTimes->{__}] -> Sequence[], Infinity]
  // Replace[#, HoldPattern[TrackCellChangeTimes->True] -> Sequence[], Infinity] &
)

removeWinInfo[nb_] :=
  Replace[nb, { HoldPattern[WindowSize->{__}] -> Sequence[]
              , HoldPattern[WindowMargins->{__}] -> Sequence[] }, 1];

disableCache[nb_] :=
  With[{ opts = Rest[List @@ nb] },
  With[{ privopt = PrivateNotebookOptions /. opts },
  With[{ flag    = Quiet[Check["FileOutlineCache" /. privopt, false], ReplaceAll::reps] },
    Which[( "Symbol" == SymbolName[Head[privopt]] ),
            Append[nb, PrivateNotebookOptions -> {"FileOutlineCache" -> False}],
          ( TrueQ[flag] ),
            Replace[nb, HoldPattern["FileOutlineCache"->True] -> ("FileOutlineCache"->False), 3],
          ( False === flag ),
            nb,
          ( True ),
            Replace[nb , HoldPattern[PrivateNotebookOptions -> {o__}] ->
                         (PrivateNotebookOptions -> {o, "FileOutlineCache" -> False }), 1 ]
    ]
  ]]]

(* NOTE: returns String *)
(* TODO: handle fail case *)
removeCacheInfo[nb_] := (
  ExportString[nb, "NB"]
  // Last[StringSplit[#, "(* Beginning of Notebook Content *)"]] &
  // StringReplace[#, RegularExpression["^\\s"] -> ""] &
  // First[StringSplit[#, "(* End of Notebook Content *)"]] &
)


processFile[filename_] := (
  Check[Import[filename, "NB"], die["Failed to import" <> filename, 2]]
  // If[Config`keepOutputCell, #, removeOutputCells[#]] &
  // removeChangeTime
  // removeWinInfo
  // disableCache
  // removeCacheInfo
)

(* parse arguments *)
Catch[
  ParseArg`ParseArg[Rest[$ScriptCommandLine],
    {
      "h" :> (printUsage[]; Exit[0]),
      "O" :> (Config`keepOutputCell = True),
      "o" :> (Config`output = ReadString[]),
      "default" :> If[Config`input == "", Config`input = CurrentToken[]
                                        , Throw["got multiple input files"], EParseArg],
      _ :> Throw["Invalid flag -" <> CurrentFlag[], EParseArg]
    }
  ],
  EParseArg,
  ( WriteString["stderr", "Error: " <> ToString[#1] <> "\n"]
  ; printUsage[]
  ; Exit[1]
  ) &
]

(* verify arguments *)
If[Config`input == "", die["no input file is given", 1], Null]

If[Config`output == "",
  Config`output = StringReplace[Config`input, {
    ".nb" -> ".strip.nb",
    ".cdf" -> ".strip.cdf"
  }],
  Null
]

(* process file *)
Module[{nb, fp},
  Check[nb = processFile[Config`input],
    die["an error has occured while processing " <> Config`input, 255]];

  Check[fp = OpenWrite[Config`output],
    die["cannot open output file '" <> Config`output <> "' for writing", 1]];

  Check[WriteString[fp, nb],
    die["failed to write to the output file", 100]];
]
