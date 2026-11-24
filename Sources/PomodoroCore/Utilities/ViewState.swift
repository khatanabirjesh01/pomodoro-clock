import SwiftUI

/// A drop-in property wrapper that safely wraps `SwiftUI.State<Value>` while conforming to `DynamicProperty`,
/// ensuring seamless UI state updates across all versions of the Swift toolchain.
@propertyWrapper
public struct ViewState<Value>: DynamicProperty {
    private var state: SwiftUI.State<Value>
    
    public init(wrappedValue: Value) {
        self.state = SwiftUI.State(initialValue: wrappedValue)
    }
    
    public init(initialValue: Value) {
        self.state = SwiftUI.State(initialValue: initialValue)
    }
    
    public var wrappedValue: Value {
        get { state.wrappedValue }
        nonmutating set { state.wrappedValue = newValue }
    }
    
    public var projectedValue: Binding<Value> {
        state.projectedValue
    }
}
