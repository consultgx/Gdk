# Gdk

GDK is swift package for generalized utilities and helpers

Few swift best practices

// https://www.swift.org/documentation/api-design-guidelines/

// Swift linter- https://github.com/realm/SwiftLint

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

// @frozen marked for enum declaration

// final marked for class declaration- helps compiler optimization

// start private and then public if needed

// prefers actors as they are better bridge between reference and value types

// for constant and state declarations use enums

// when needed to enforce concreteness prefer generics over prototypes or have generic associate type in prototype.

// prefer programmatic ui set up and its constraints set up over storyboard and their loads for uikit, else swiftui

// method, message names should be crud like or api resource like descriptive but succinct, getReply setMessage

// use Result type for function returns where you can, Or concrete type return with throwable functions

