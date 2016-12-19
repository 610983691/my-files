## Runnable 接口 ##

    public interface Runnable {
    /**
     * When an object implementing interface <code>Runnable</code> is used
     * to create a thread, starting the thread causes the object's
     * <code>run</code> method to be called in that separately executing
     * thread.
     * <p>
     * The general contract of the method <code>run</code> is that it may
     * take any action whatsoever.
     *
     * @see     java.lang.Thread#run()
     */
    public abstract void run();
}

## Thread 类 ##
API描述：
> 线程 是程序中的执行线程。Java 虚拟机允许应用程序并发地运行多个执行线程。
> 
每个线程都有一个优先级，高优先级线程的执行优先于低优先级线程。每个线程都可以或不可以标记为一个守护程序。当某个线程中运行的代码创建一个新 Thread 对象时，该新线程的初始优先级被设定为创建线程的优先级，并且当且仅当创建线程是守护线程时，新线程才是守护程序。
> 
当 Java 虚拟机启动时，通常都会有单个非守护线程（它通常会调用某个指定类的 main 方法）。Java 虚拟机会继续执行线程，直到下列任一情况出现时为止：
> 
调用了 Runtime 类的 exit 方法，并且安全管理器允许退出操作发生。
非守护线程的所有线程都已停止运行，无论是通过从对 run 方法的调用中返回，还是通过抛出一个传播到 run 方法之外的异常。
创建新执行线程有两种方法。一种方法是将类声明为 Thread 的子类。该子类应重写 Thread 类的 run 方法。接下来可以分配并启动该子类的实例。


----------
几个本地方法：

    /**
     * Returns a reference to the currently executing thread object.
     *
     * @return  the currently executing thread.
     * 看这段话的意思是返回一个当前执行的线程对象的引用
     * 但是你在Thread.currentThread()，就是说看当前哪个线程在执行这个语句咯。
     */
    public static native Thread currentThread();