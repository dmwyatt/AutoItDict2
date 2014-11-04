#include <Constants.au3>
#include <micro/micro.au3>
#include <Dict2.au3>

$testSuite = newTestSuite("Dict2 Test Suite")

$testSuite.addTest(testCreate())
$testSuite.addTest(testCreateWithInitial())
$testSuite.addTest(testCreateWithErroneousParameters())
$testSuite.addTest(testIsDict())
$testSuite.addTest(testIsDict2())
$testSuite.addTest(testSettingAndGetting())
$testSuite.addTest(testDeleting())
$testSuite.addTest(testKeyMethods())
$testSuite.addTest(testLen())
$testSuite.addTest(testContains())
$testSuite.addTest(testPairs())
$testSuite.addTest(testValues())


$testSuite.finish()

Func testCreate()
  $test = newTest("_DictCreate raises no errors and returns an obj")
  $dict = _DictCreate()

  $test.assertFalse("no @error raised", @error)
  $test.assertTrue("returns an object", IsObj($dict))
  $test.assertTrue("returns an object with appropriate value for id property", $dict.__dict_object_identifier = $__dict2_obj_id)

  Return $test
EndFunc

Func testCreateWithInitial()
  $test = newTest("_DictCreate creates dictionary with initial data")
  Local $aInitialData[2][2] = [["key1", "value1"], ["key2", "value2"]]
  $dict = _DictCreate($aInitialData)

  $fValid = $dict.get("key1") == "value1" And $dict.get("key2") == "value2"
  $test.assertTrue("returns dict with appropriate keys and values", $fValid)

  Return $test
EndFunc

Func testCreateWithErroneousParameters()
  $test = newTest("_DictCreate identifies incorrect parameters")
  $dict = _DictCreate(1)

  $err = @error
  $test.assertEquals("returns $DICT2_DICT_CREATION_FAIL when receive a non-array for initial data", $dict, $DICT2_DICT_CREATION_FAIL)
  $test.assertEquals("sets @error to $DICT2_NON_ARRAY_INITIAL when initial data is not an array", $err, $DICT2_NON_ARRAY_INITIAL)

  Local $aInvalidArray[1] = ["wrong"]
  $dict = _DictCreate($aInvalidArray)

  $err = @error
  $test.assertEquals("returns $DICT2_DICT_CREATION_FAIL when array received for initial data has wrong dimensions", $dict, $DICT2_DICT_CREATION_FAIL)
  $test.assertEquals("sets @error to $DICT2_WRONG_ARRAY_DIMENSIONS when array dimensions are incorrect", $err, $DICT2_WRONG_ARRAY_DIMENSIONS)

  Return $test
EndFunc

Func testIsDict()
  $test = newTest("IsDict correctly identifies a dict")
  $dict = _DictCreate()

  $test.assertTrue("returns True for empty dict", IsDict($dict))
  $dict.add("key1", "value1")
  $test.assertTrue("returns True for non-empty dict", IsDict($dict))

  Return $test
EndFunc

Func testIsDict2()
  $test = newTest("IsDict correctly identifies non-dicts")
  $NotADict = ObjCreate("Scripting.Dictionary")

  $test.assertFalse("regular scripting.dictionary is not a Dict", IsDict($NotADict))
  $test.assertFalse("string is not a Dict", IsDict("hi"))
  $test.assertFalse("Int is not a Dict", IsDict(1))

  Return $test
EndFunc

Func testSettingAndGetting()
  $test = newTest("Dicts can have key-value pairs created")
  $dict = _DictCreate()

  $dict.set("key", "value")
  $test.assertEquals("can retrieve a set value", $dict.get("key"), "value")

  For $i = 0 To 100
    $dict.set("key" & $i, "value" & $i)
  Next
  $test.assertEquals("can retrieve a set value when more than one value in dict", $dict.get("key24"), "value24")

  $dict.set("key24", "value24redo")
  $test.assertEquals("can retrieve a value when set over a previous value", $dict.get("key24"), "value24redo")

  Return $test
EndFunc

Func testDeleting()
  $test = newTest("Deleting key-value pairs from dictionary is possible")
  $dict = _DictCreate()

  $dict.set("key1", "value1")
  $dict.del("key1")
  $test.assertEquals("deleted a lone key-value pair", $dict.len, 0)

  For $i = 0 To 100
    $dict.set("key" & $i, "value" & $i)
  Next

  $dict.del("key24")
  $fExists = $dict.contains("key24")
  $test.assertFalse("deleted a key-value pair from 'middle' of dict", $fExists)

  $dict.del_all()
  $test.assertEquals("deleted all key-value pairs", $dict.len, 0)

  Return $test
EndFunc

Func testKeyMethods()
  $test = newTest("Methods pertaining to keys work as expected")
  $dict = _DictCreate()

  For $i = 1 To 100
    $dict.set("key" & $i, "value" & $i)
  Next

  $test.assertTrue("can tell if existent key actually exists", $dict.contains("key24"))
  $test.assertFalse("can tell if non-existent key doesn't exist", $dict.contains("key1000"))

  $aKeys = $dict.keys()

  $good = True
  If UBound($aKeys) <> 100 Then $good = False
  If $good Then
    For $i = 0 To 99
      If Not StringRegExp($aKeys[$i], "key\d{1,3}") Then
        $good = False
        ExitLoop
      EndIF
    Next
  EndIf
  $test.assertTrue("can get array of keys from dict", $good)

  Return $test
EndFunc

Func testLen()
  $test = newTest("Dict.len() returns correct values")
  $dict = _DictCreate()

  $test.assertEquals("empty dict has a len() of 0", $dict.len(), 0)

  $fGood = True
  For $i = 0 To 9
    $dict.set("key" & $i, "value" & $i)
    If $dict.len() <> $i + 1 Then $fGood = False
  Next

  $test.assertTrue("dict.len() returns correct value for various lengths", $fGood)

  Return $test
EndFunc

Func testContains()
  $test = newTest("Dict.contains works correctly")
  $dict = _DictCreate()

  $test.assertFalse("empty dict doesn't contain anything", $dict.contains("nope"))

  $dict.set("no", "yes")
  $test.assertTrue("dict with one key-value pair contains that key", $dict.contains("no"))

  $dict.del("no")
  $test.assertFalse("dict with key deleted doesn't contain that key", $dict.contains("no"))


  For $i = 0 To 99
    $dict.set("key" & $i, "value" & $i)
  Next

  $test.assertTrue("dict with many items contains one of them", $dict.contains("key10"))
  $test.assertFalse("dict with many items doesn't contain item that doesn't exist", $dict.contains("no"))

  Return $test
EndFunc

Func testPairs()
  $test = newTest("Dict.pairs works correctly")
  $dict = _DictCreate()

  $test.assertFalse("empty dict has no pairs", $dict.pairs())

  For $i = 0 To 99
    $dict.set("key" & $i, "value" & $i)
  Next

  $aPairs = $dict.pairs()
  $test.assertTrue("dict with 100 items returns array for Dict.pairs()", IsArray($aPairs))
  $test.assertEquals("dict.pairs() with 100 items returns array with 100 rows", UBound($aPairs), 100)
  $test.assertEquals("dict.pairs() with 100 items returns array with 2 columns", UBound($aPairs, $UBOUND_COLUMNS), 2)

  $fGood = True
  For $i = 0 To 99
    If $aPairs[$i][1] <> $dict.get($aPairs[$i][0]) Then $fGood = False
  Next
  $test.assertTrue("dict with 100 items returns array with each row being a key-value pair", $fGood)


  Return $test
EndFunc

Func testValues()
  $test = newTest("Dict.values works correctly")
  $dict = _DictCreate()

  $test.assertFalse("empty dict has no values", $dict.values())

  For $i = 0 To 99
    $dict.set("key" & $i, "value" & $i)
  Next

  $aValues = $dict.values()
  $test.assertTrue("dict with 100 items returns array for Dict.values()", IsArray($aValues))
  $test.assertEquals("dict.pairs() with 100 items returns array with 100 rows", UBound($aValues), 100)
  $test.assertEquals("dict.pairs() with 100 items returns array with 1 columns", UBound($aValues, $UBOUND_COLUMNS), 0)

  $fGood = True
  For $i = 0 To UBound($aValues) - 1
    $sKey = StringReplace($aValues[$i], "value", "key")
    If Not $aValues[$i] == $dict.get($sKey) Then $fGood = False
  Next
  $test.assertTrue("dict.pairs with 100 items returns accurate values ", $fGood)

  Return $test
EndFunc