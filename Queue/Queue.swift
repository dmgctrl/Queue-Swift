import Dispatch


public struct Queue: Equatable {
    var queue: dispatch_queue_t
    
    public init() {
        self.queue = dispatch_queue_create(nil, nil)
    }
    
    public init(_ queue: dispatch_queue_t) {
        self.queue = queue
    }
    
    public func sync<T>(block: () -> T, barrier: Bool = false) -> T {
        var result: T? = nil
        sync({
            result = block()
        }, barrier: barrier)
        return result!
    }
   
    public func sync(block: () -> (), barrier: Bool = false) {
        if barrier {
            dispatch_barrier_sync(queue, block)
        } else {
            dispatch_sync(queue, block)
        }
    }
    
    public func async(block: () -> (), barrier: Bool = false) {
        if barrier {
            dispatch_barrier_async(queue, block)
        } else {
            dispatch_async(queue, block)
        }
    }
    
    public func after(delayInNanos: Int64, _ block: () -> ()) {
        assert(delayInNanos >= 0, "We can't dispatch into the past.")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInNanos), queue, block)
    }
    
    public func withTarget(target: Queue) -> Queue {
        dispatch_set_target_queue(self.queue, target.queue)
        return self
    }
    
    public func suspend() -> Queue {
        dispatch_suspend(queue)
        return self
    }
    
    public func resume() -> Queue {
        dispatch_resume(queue)
        return self
    }

    public static let Main = Queue(dispatch_get_main_queue())
    public static let Background = Queue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
}


public func ==(lhs: Queue, rhs: Queue) -> Bool {
    return lhs.queue === rhs.queue
}