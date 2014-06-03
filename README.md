SwiftVerbalExpressions
======================

Swift Regular expressions made easy


## Examples

```swift
// Create an example of how to test for correctly formed URLs
let tester = VerEx()
    .startOfLine()
    .then( "http" )
    .maybe( "s" )
    .then( "://" )
    .maybe( "www." )
    .anythingBut( " " )
    .endOfLine()

// Create an example URL
let testMe = "https://www.google.com"

// Now test the URL
if tester.test(testMe) {
    println("We have a correct URL!")
}
else {
    println("The URL is incorrect!")
}
```
