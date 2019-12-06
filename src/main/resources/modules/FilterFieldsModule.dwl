%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

fun parseFieldsFilter(fieldsList) =
	do {
	 var fields = fieldsList default "" splitBy ","  filter (value) -> (value != "*all")
	 ---
	 {
	 	fields: fields,
	 	"type": fields match {
	 		case items if sizeOf (items) == 0 -> "*"
	 		case items if items every ($ startsWith "-") -> "-"
	 		else -> "+"
	 	}
	 }
	}

fun filterBy(payload, fieldsList) = 
	do{
		var filter = parseFieldsFilter(fieldsList)
		---
		payload match {
			case is Array -> payload map filterItem($, filter)
			case is Object -> filterItem(payload, filter)
			else -> payload
		}	
	}
	
fun filterItem(payload, filter) = 
	filter."type" match {
		case "*" -> payload
		case "-" -> negativeFilter(payload, filter)
		case "+" -> positiveFilter(payload, filter)
		else -> payload
	}

fun negativeFilter(payload, filter) = payload -- (filter.fields map substringAfter($, "-")) 

fun positiveFilter(payload, filter) = log(payload filterObject ((value, key) -> filter.fields contains key as String))
	