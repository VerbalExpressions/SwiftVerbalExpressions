SwiftVerbalExpressions
======================


## Swift Regular Expressions made easy

SwiftVerbalExpressions is a Swift library that helps to construct difficult regular expressions - ported from the awesome JavaScript [VerbalExpressions](https://github.com/jehna/VerbalExpressions).


## Examples

Here's a couple of simple examples to give an idea of how VerbalExpressions works:

### Testing if we have a valid URL

```swift
// Create an example of how to test for correctly formed URLs
let tester = VerEx()
    .startOfLine()
    .then("http")
    .maybe("s")
    .then("://")
    .maybe("www")
    .anythingBut(" ")
    .endOfLine()

// Create an example URL
let testMe = "https://www.google.com"

// Use test() method
if tester.test(testMe) {
    println("We have a correct URL") // This output will fire
}
else {
    println("The URL is incorrect")
}

// Use =~ operator
if testMe =~ tester {
    println("We have a correct URL") // This output will fire
}
else {
    println("The URL is incorrect")
}

println(tester) // Outputs the actual expression used: "^(?:http)(?:s)?(?::\/\/)(?:www)?(?:[^ ]*)$"
```

### Replacing strings

```swift
let replaceMe = "Replace bird with a duck"

// Create an expression that seeks for word "bird"
let verEx = VerEx().find("bird")

// Execute the expression like a normal RegExp object
let result = verEx.replace(replaceMe, with: "duck")

println(result) // Outputs "Replace duck with a duck"
```

### Shorthand for string replace:

```swift
let result2 = VerEx().find("red").replace("We have a red house", with: "blue")

println(result2) // Outputs "We have a blue house"
```


## API documentation

You can find the documentation for the original JavaScript repo on their [wiki](https://github.com/jehna/VerbalExpressions/wiki).


## Contributions

Clone the repo and fork!
Pull requests are warmly welcome!


## Thanks!

Thank you to @jehna for coming up with the awesome original idea!  
Thank you to @kishikawakatsumi for ObjectiveCVerbalExpressions from which I borrowed some code!


## Other implementations

You can view all implementations on [VerbalExpressions.github.io](http://VerbalExpressions.github.io)
