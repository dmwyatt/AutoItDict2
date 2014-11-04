AutoItDict2
===========

An implementation of a dictionary type for AutoIt.

Reasons
=======
Created for the following reasons..

* Wanted to get a basic understanding of AutoItObject.
* Wanted to get a basic understanding of the Micro unit test framework.
* AutoIt has no native dict or associative array type.
* It's laborious to use `Scripting.dictionary` all the time.
* The Python dict API is better than `Scripting.dictionary`'s

Examples
========
```autoit
#include <Dict2.au3>
#include <Array.au3>

$dict = _DictCreate()
ConsoleWrite($dict.len()) ; Outputs 0

$dict.set("key1", "value1")
$dict.set("key2", "value2")
$dict.set("key3", "value3")
$dict.set("key4", 1)

ConsoleWrite($dict.get("key2"))         ; Outputs 'value2'
ConsoleWrite($dict.len())               ; Outputs 3
ConsoleWrite($dict.contains("key2")     ; Outputs True

$dict.set("key4", $dict.get("key4") + 1)
ConsoleWrite($dict.get("key4"))         ; Outputs 2

$dict.del("key4")
ConsoleWrite($dict.contains("key4"))    ; Outputs False

$aPairs = $dict.pairs()
_ArrayDisplay($aPairs)                  ; Displays 2d array with column one contains keys, and column two 
                                        ; containing associated values

$aKeys = $dict.keys()
_ArrayDisplay($aKeys)                   ; Displays array containing all keys

$aValues = $dict.values()
_ArrayDisplay($aValues)                 ; Displays array of all values

$aDesiredKeys = ["key1", "key3"]
$aValues = $dict.values($aDesiredKeys)
_ArrayDisplay($aValues)                 ; Displays array of values for key1 and key3
```
