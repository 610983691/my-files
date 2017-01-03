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


可以参考下面这篇文章，写的很清楚：

[http://www.cnblogs.com/dolphin0520/p/3920357.html](http://www.cnblogs.com/dolphin0520/p/3920357.html "Thread线程分析")

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

线程状态：
    
	public static enum Thread.State
     

      extends 
      Enum<
      Thread.State>
     
线程状态。线程可以处于下列状态之一：

> NEW
> 至今尚未启动的线程处于这种状态。
> 
> RUNNABLE
> 正在 Java 虚拟机中执行的线程处于这种状态。
> 
> BLOCKED
> 受阻塞并且正在等待监视器锁的某一线程的线程状态。处于受阻塞状态的某一线程正在等待监视器锁，以便进入一个同步的块/方法，或者在调用 Object.wait 之后再次进入同步的块/方法。
> 
> WAITING
> 某一等待线程的线程状态。某一线程因为调用下列方法之一而处于等待状态：
不带超时值的 Object.wait
不带超时值的 Thread.join
LockSupport.park
处于等待状态的线程正等待另一个线程，以执行特定操作。 例如，已经在某一对象上调用了 Object.wait() 的线程正等待另一个线程，以便在该对象上调用 Object.notify() 或 Object.notifyAll()。已经调用了 Thread.join() 的线程正在等待指定线程终止。
> 
> TIMED_WAITING
> 具有指定等待时间的某一等待线程的线程状态。某一线程因为调用以下带有指定正等待时间的方法之一而处于定时等待状态：
Thread.sleep
带有超时值的 Object.wait
带有超时值的 Thread.join
LockSupport.parkNanos
LockSupport.parkUntil
> 
> TERMINATED
> 已退出的线程处于这种状态。


> 在给定时间点上，一个线程只能处于一种状态。这些状态是虚拟机状态，它们并没有反映所有操作系统线程状态。
> 
----------
几个本地方法：

	/* Make sure registerNatives is the first thing <clinit> does. */
	//这个是类加载的时候就必须做的动作
    private static native void registerNatives();
    static {
        registerNatives();
    }

    /**
     * Returns a reference to the currently executing thread object.
     *
     * @return  the currently executing thread.
     * 看这段话的意思是返回一个当前执行的线程对象的引用
     * 但是你在Thread.currentThread()，就是说看当前哪个线程在执行这个语句咯。
     */
    public static native Thread currentThread();

	
	/**
	*暂停当前正在执行的线程对象，并执行其他相同优先级的线程。如果没有相同优先级的线程，这个方法无效。---但它并不保证当前线程会被JVM再次调度、使该线程重新进入Running状态
	*/
	public static native void yield();	

	/**
	*在指定的毫秒数内让当前正在执行的线程休眠（暂停执行），此操作受到系统计时器和调度程序精度和准确性的影响。该线程不丢失任何监视器的所属权。--即它不会丢失锁
	*/
	public static native void sleep(long millis) throws InterruptedException;

	/**
	*当且仅当当前线程在指定的对象上obj保持监视器锁时，才返回 true。
	该方法旨在使程序能够断言当前线程已经保持一个指定的锁：
	assert Thread.holdsLock(obj);
	如果obj==null，就抛空指针异常。
	*/
	public static native boolean holdsLock(Object obj);

	//将线程置为可执行RUNNALBLE状态
	private native void start0();

	/**
     * Tests if some Thread has been interrupted.  The interrupted state
     * is reset or not based on the value of ClearInterrupted that is
     * passed.
     */
    private native boolean isInterrupted(boolean ClearInterrupted);

	/**
     * Tests if this thread is alive. A thread is alive if it has
     * been started and has not yet died.
     *
     * @return  <code>true</code> if this thread is alive;
     *          <code>false</code> otherwise.
     * 查看某个线程是否处于活动状态，即已经start 但是又没有被终止(TERMINATE)
     */
    public final native boolean isAlive();

	private native static StackTraceElement[][] dumpThreads(Thread[] threads);
    private native static Thread[] getThreads();

	//    /* Some private helper methods */
	   private native void setPriority0(int newPriority);
	   private native void stop0(Object o);
	   private native void suspend0();
	   private native void resume0();
	   private native void interrupt0();
	   private native void setNativeName(String name);


----------
上面列出的是Thread类中用到的本地方法，这些方法底层编写好，用于和CPU打交道，对外公布的方法用到了这些本地方法。


----------
下面是线程的构造方法，或者说初始化方法：
	
	public Thread() {
        init(null, null, "Thread-" + nextThreadNum(), 0);
    }

	public Thread(Runnable target) {
        init(null, target, "Thread-" + nextThreadNum(), 0);
    }
	
	Thread(Runnable target, AccessControlContext acc) {
        init(null, target, "Thread-" + nextThreadNum(), 0, acc);
    }
	...
	...
可以看出，他们都是最后调用一个私有的init方法来对线程进行初始化的，现在我们就来看看init方法是如何进行初始化的。
	
    /**
     * Initializes a Thread.
     *
     * @param g the Thread group
     * @param target the object whose run() method gets called
     * @param name the name of the new Thread
     * @param stackSize the desired stack size for the new thread, or
     *        zero to indicate that this parameter is to be ignored.
     * @param acc the AccessControlContext to inherit, or
     *            AccessController.getContext() if null
     */
    private void init(ThreadGroup g, Runnable target, String name,
                      long stackSize, AccessControlContext acc) {
        if (name == null) {
            throw new NullPointerException("name cannot be null");
        }

        this.name = name.toCharArray();

        Thread parent = currentThread();//创建的线程默认就是当前执行线程的子线程
        SecurityManager security = System.getSecurityManager();//获取系统的安全策略
        if (g == null) {
            /* Determine if it's an applet or not */

            /* If there is a security manager, ask the security manager
               what to do. */
            if (security != null) {
                g = security.getThreadGroup();//获取系统的security线程组
            }

            /* If the security doesn't have a strong opinion of the matter
               use the parent thread group. */
            if (g == null) {
                g = parent.getThreadGroup();//如果上面的if没有拿到，就获取它父线程的线程组
            }
        }

        /* checkAccess regardless of whether or not threadgroup is
           explicitly passed in. */
        g.checkAccess();

        /*
         * Do we have the required permissions?
         */
        if (security != null) {
            if (isCCLOverridden(getClass())) {
                security.checkPermission(SUBCLASS_IMPLEMENTATION_PERMISSION);
            }
        }

        g.addUnstarted();//线程组会计数，记录当前还没start的线程的数量

        this.group = g;
        this.daemon = parent.isDaemon();//都是从父线程那里继承来的
        this.priority = parent.getPriority();//线程优先级
        if (security == null || isCCLOverridden(parent.getClass()))
            this.contextClassLoader = parent.getContextClassLoader();
        else
            this.contextClassLoader = parent.contextClassLoader;
        this.inheritedAccessControlContext =
                acc != null ? acc : AccessController.getContext();
        this.target = target;
        setPriority(priority);
        if (parent.inheritableThreadLocals != null)
            this.inheritableThreadLocals =
                ThreadLocal.createInheritedMap(parent.inheritableThreadLocals);
        /* Stash the specified stack size in case the VM cares */
        this.stackSize = stackSize;

        /* Set thread ID */
        tid = nextThreadID();
    }


----------

常用到的方法分析：

	//sleep带纳秒的方法其实就是对纳秒数进行了 四舍五入而已。最后都是通过调用线程的sleep本地方法来实现的。
    public static void sleep(long millis, int nanos)
    throws InterruptedException {
        if (millis < 0) {
            throw new IllegalArgumentException("timeout value is negative");
        }

        if (nanos < 0 || nanos > 999999) {
            throw new IllegalArgumentException(
                                "nanosecond timeout value out of range");
        }

        if (nanos >= 500000 || (nanos != 0 && millis == 0)) {
            millis++;
        }

        sleep(millis);
    }

	

	//启动线程--但不一定就开始执行，执行需要由CPU来调度。
	public synchronized void start() {
        /**
         * This method is not invoked for the main method thread or "system"
         * group threads created/set up by the VM. Any new functionality added
         * to this method in the future may have to also be added to the VM.
         *
         * A zero status value corresponds to state "NEW".
         */
        if (threadStatus != 0)
            throw new IllegalThreadStateException();

        /* Notify the group that this thread is about to be started
         * so that it can be added to the group's list of threads
         * and the group's unstarted count can be decremented. */
        group.add(this);

        boolean started = false;
        try {
            start0();
            started = true;
        } finally {
            try {
                if (!started) {
                    group.threadStartFailed(this);
                }
            } catch (Throwable ignore) {
                /* do nothing. If start0 threw a Throwable then
                  it will be passed up the call stack */
            }
        }
    }

    private native void start0();


	public void run() {
        if (target != null) {
            target.run();
        }
    }

    /**
     * This method is called by the system to give a Thread
     * a chance to clean up before it actually exits.
     * 把所有的状态都清空，并且从线程组中移除
     */
    private void exit() {
        if (group != null) {
            group.threadTerminated(this);
            group = null;
        }
        /* Aggressively null out all reference fields: see bug 4006245 */
        target = null;
        /* Speed the release of some of these resources */
        threadLocals = null;
        inheritableThreadLocals = null;
        inheritedAccessControlContext = null;
        blocker = null;
        uncaughtExceptionHandler = null;
    }


	注意stop方法，它被废弃是因为执行的时候，立马就会被停止。在同步块中也会被停止，这样就会导致同步块中的变量状态可能不一致。这是并发不允许的

	如：
	synchronized(o){
		x =10; //执行到这里时，stop，那么y的值不会被修改，没有起到同步块应有的作用
		y =20;
	}

----------
	// 调用该方法相当于就是将该线程的中断状态设置为true
    public void interrupt() {
        if (this != Thread.currentThread())//如果不是它自己就会checkAccess
            checkAccess();//这个方法有可能会抛异常

        synchronized (blockerLock) {
            Interruptible b = blocker;
            if (b != null) {
                interrupt0();           // Just to set the interrupt flag
                b.interrupt(this); //将当前线程中断
                return;
            }
        }
        interrupt0();
    }

	//测试当前线程是否已经中断。线程的 中断状态 由该方法清除。换句话说，如果连续两次调用该方法，则第二次调用将返回 false（在第一次调用已清除了其中断状态之后，且第二次调用检验完中断状态前，当前线程再次中断的情况除外）。
	线程中断被忽略，因为在中断时不处于活动状态的线程将由此返回 false 的方法反映出来。
	如果当前线程已经中断，则返回 true；否则返回 false。
	public static boolean interrupted() {
        return currentThread().isInterrupted(true);
    }

	//只判断是否中断，不会修改中断状态
	如果该线程已经中断，则返回 true；否则返回 false。
	public boolean isInterrupted() {
        return isInterrupted(false);
    }



----------

    /**
     * Determines if the currently running thread has permission to
     * modify this thread.
     * <p>
     * If there is a security manager, its <code>checkAccess</code> method
     * is called with this thread as its argument. This may result in
     * throwing a <code>SecurityException</code>.
     *
     * @exception  SecurityException  if the current thread is not allowed to
     *               access this thread.
     * @see        SecurityManager#checkAccess(Thread)
     */
    public final void checkAccess() {
        SecurityManager security = System.getSecurityManager();
        if (security != null) {//没有安全管理器的话，那就是说权限都是开放的，随便整，所以会通过。--但是这个情况应该不会有吧 ？
            security.checkAccess(this);
        }
    }
	//获取类加载器
	public ClassLoader getContextClassLoader() {
        if (contextClassLoader == null)
            return null;

        SecurityManager sm = System.getSecurityManager();
        if (sm != null) {//安全管理器的权限校验--里面会涉及访问控制器等一系列的系统安全性校验，不通过的话会抛出异常
            ClassLoader.checkClassLoaderPermission(contextClassLoader,
                                                   Reflection.getCallerClass());
        }
        return contextClassLoader;
    }

	Thread类中有一个join()方法，在一个线程中启动另外一个线程的join方法，当前线程将会挂起，而执行被启动的线程，直到被启动的线程执行完毕后，当前线程才开始执行。

	public final synchronized void join(long millis)
    throws InterruptedException {
        long base = System.currentTimeMillis();
        long now = 0;

        if (millis < 0) {
            throw new IllegalArgumentException("timeout value is negative");
        }

        if (millis == 0) {
            while (isAlive()) {//要执行的线程this 如果不是活动状态，那么就直接退出该方法了
                wait(0);
            }
        } else {
            while (isAlive()) {
                long delay = millis - now;
                if (delay <= 0) {
                    break;
                }
                wait(delay);
                now = System.currentTimeMillis() - base;
            }
        }
    }

	wait方法会让线程进入阻塞状态，并且会释放线程占有的锁，并交出CPU执行权限。

　　由于wait方法会让线程释放对象锁，所以join方法同样会让线程释放对一个对象持有的锁。具体的wait方法使用在后面文章中给出。

	自己写了个测试方法：
	public class TestThread {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		TestThread tt = new TestThread();
		Thread1 t1 = tt.new Thread1();
		Thread2 t2 = tt.new Thread2();
		t2.setThread1(t1);
		t1.start();
		t2.start();

	}

	class Thread1 extends Thread {

		public void run() {
			try {
				System.out.println(
						"thread1 runing.now=  " + System.currentTimeMillis());
				sleep(5000);
			} catch (Exception e) {
				// TODO: handle exception
				e.printStackTrace();
			}
			System.out.println(
					"thread1 run over.now=" + System.currentTimeMillis());
		}
	}

	class Thread2 extends Thread {
		Thread1 threa1 = null;
		public void run() {
			try {
				System.out.println(
						"thread2 runing.now=  " + System.currentTimeMillis());
				sleep(2000);
				threa1.join(1000);//如果不指定时间，这里thread2就会等thread1执行完了才执行
			} catch (Exception e) {
				// TODO: handle exception
				e.printStackTrace();
			}
			System.out.println(
					"thread2 run over.now=" + System.currentTimeMillis());
		}
		void setThread1(Thread1 t) {
			this.threa1 = t;
		}
	}
	}


	这里还是有点没搞懂的，继续：
	在thread2的run方法里面，这样写：
	sleep(2000);
	this.join();//这样写，程序永远不会停止，它自己等自己执行完。。。所以等不到这个状态

	这样写：
	sleep(2000);
	threa1.join();//main里面不调用t1.start（），那么在join方法里面isAlive为false.t2线程就不会等待
	
----------

	