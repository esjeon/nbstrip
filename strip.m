#!/home/eon/bin/MathematicaScript -script
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


die[msg_, n_] := (
  WriteString["stderr", msg, "\n"];
  Exit[n]
)

removeOutputCells[nb_] :=
  Replace[nb, HoldPattern[Cell[_,"Output",__]]   -> Sequence[], 5]

removeChangeTime[nb_] := (
  Replace[nb, HoldPattern[CellChangeTimes->{__}] -> Sequence[], Infinity]
  // Replace[#, HoldPattern[TrackCellChangeTimes->True] -> Sequence[], 5] &
)

removeWinInfo[nb_] :=
  Replace[nb, { HoldPattern[WindowSize->{__}] -> Sequence[]
              , HoldPattern[WindowMargins->{__}] -> Sequence[] }, 1];

disableCache[nb_] :=
  With[{ opts = Rest[List @@ nb] },
  With[{ privopt = PrivateNotebookOptions /. opts },
  With[{ flag    = Check["FileOutlineCache" /. privopt, false] },
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
  Import[filename, "NB"]
  // Check[ #, die["Failed to import" <> filename, 2] ] &
  // removeOutputCells
  // removeChangeTime
  // removeWinInfo
  // disableCache
  // removeCacheInfo
)
                

main[argc_, argv_] :=
  Which[(argc == 1), WriteString["stderr", "a filename is required", "\n"];
                     1,
        (argc != 2), WriteString["stderr", "TODO: Usage\n"];
                     1,
        (True), With[{ filename = argv[[2]] },
                  WriteString["stderr", "processing ", filename, "\n"];
                  (
                    processFile[filename]
                    // Check[#, die["an error has occured while processing " <> filename, 255]] &
                    // WriteString[OpenWrite["output.nb"], #] &
                    // Check[#, die["failed to write to the output file", 100]] &
                  )
                ];
                0
  ] // Quit


main[Length[$ScriptCommandLine],
     $ScriptCommandLine]

