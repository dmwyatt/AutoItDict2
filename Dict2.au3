#include <AutoItObject\AutoItObject.au3>
#include <Array.au3>
#include <Constants.au3>
#include-once

Global Const $DICT2_DICT_CREATION_FAIL = -1
Global Const $DICT2_NON_ARRAY_INITIAL = 1
Global Const $DICT2_WRONG_ARRAY_DIMENSIONS = 2

_AutoItObject_StartUp()


Func _DictCreate($aInitial=Default, $oIDMe=Default)
  ; Limit global vars by putting this in here.  It's kinda yucky, but oh well.
  Local $_obj_id = "la;jsd0f9j'34j5;lkdjf[0asuejlakjsd;flj345109j;lajks;lejkr039uj5q;okjas;lkdjf;lkj0q9j;lakj"
  If $oIDMe <> Default Then
    Return $oIDMe.__dict_object_identifier = $_obj_id
  EndIf

  ; Create object and dictionary
  Local $this = _AutoItObject_Class()
  Local $_dict = ObjCreate("Scripting.Dictionary")

  ; If we have initial key-value pairs, add them to the dict
  If $aInitial <> Default Then
    If Not IsArray($aInitial) Then Return SetError($DICT2_NON_ARRAY_INITIAL, 0, $DICT2_DICT_CREATION_FAIL)
    If Not UBound($aInitial, $UBOUND_COLUMNS) == 2 Then Return SetError($DICT2_WRONG_ARRAY_DIMENSIONS, 0, $DICT2_DICT_CREATION_FAIL)

    For $i = 0 To UBound($aInitial) - 1
      $_dict.Add($aInitial[$i][0], $aInitial[$i][0])
    Next
  EndIf

  $this.Create()

  $this.AddProperty("__dict_object_identifier", $ELSCOPE_PUBLIC, $_obj_id)
  $this.AddProperty("_dict", $ELSCOPE_PRIVATE, $_dict)
  $this.AddProperty("debug_output", $ELSCOPE_PUBLIC, False)

  $this.AddMethod("set", "__set")
  $this.AddMethod("in", "__in")
  $this.AddMethod("get", "__get")
  $this.AddMethod("del", "__del")
  $this.AddMethod("len", "__len")
  $this.AddMethod("pairs", "__pairs")
  $this.AddMethod("keys", "__keys")
  $this.AddMethod("values", "__values")


  $this.AddMethod("_dbg", "__dbg")

  Return $this.Object
EndFunc

Func __set($this, $key, $value)
  If $this._dict.Exists($key) Then
    $this._dbg("Updating value for existing key")
    $this._dict.Item($key) = $value
  Else
    $this._dbg("Creating new key-value pair")
    $this._dict.Add($key, $value)
  EndIf
EndFunc

Func __in($this, $key)
  Return $this._dict.Exists($key)
EndFunc

Func __get($this, $key)
  If $this._dict.Exists($key) Then
    Return $this._dict.Item($key)
  EndIf
  $this._dbg($key & " does not exist")
EndFunc

Func __del($this, $key)
  If $this._dict.Exists($key) Then
    $this._dict.Remove($key)
  EndIf
  $this._dbg($key & " does not exist")
EndFunc

Func __len($this)
  Return $this._dict.Count
EndFunc

Func __pairs($this)
  If $this._dict.Count Then
    $this._dbg("building array for " & $this._dict.Count & " items")
    Local $aItems[$this._dict.Count][2]
    Local $aKeys = $this.keys
    For $i = 0 To $this._dict.Count - 1
      $aItems[$i][0] = $aKeys[$i]
      $aItems[$i][1] = $this.get($aKeys[$i])
    Next
    Return $aItems
  EndIf
  $this._dbg("dictionary is empty")
EndFunc

Func __keys($this)
  Return $this._dict.Keys
EndFunc

Func __values($this, $aKeyList=Default)
  If $aKeyList == Default Then Return $this._dict.Items

  Local $aValues[UBound($aKeyList)]

  For $i = 0 To UBound($aKeyList) - 1
    $aValues[$i] = $this.get($aKeyList[$i])
  Next

  Return $aValues
EndFunc

Func __dbg($this, $msg)
  If Not $this.debug_output Then Return
  ConsoleWrite($msg & @CRLF)
EndFunc

Func IsDict($dDict)
  If Not IsObj($dDict) Then Return False
  Return _DictCreate(Default, $dDict)
EndFunc