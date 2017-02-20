#任务处理相关类#
任务处理是Java常用到的功能，不知道外部开源工具使用的是何种方式。但是既然Java自带了任务处理的机制和功能，有必要对这个了解和学习。掌握一些其中的设计思想也是好的。

我目前的学习理解来说，任务处理包含Timer和TimerTask两个主要的类。其中TimerTask实现Runnable接口，Timer里边有一个内部类队列TaskQueue，因此可以简单的理解就是：把一个个的TimerTask放到Timer的队列里边，然后Timer根据FIFO原则来启动这些TimerTask线程。
后期希望自己能整理个流程图。


##Timer类
1、重要的两个类变量

     private final TaskQueue queue = new TaskQueue();

    /**
     * The timer thread.
     */
    private final TimerThread thread = new TimerThread(queue);


2、对外的公共方法
	
	//需要注意的是，如果是非周期的任务，不要调这个方法，这个方法会抛异常。应该调 schedule(TimerTask task, Date firstTime）方法
    public void schedule(TimerTask task, Date firstTime, long period) {
        if (period <= 0)
            throw new IllegalArgumentException("Non-positive period.");
        sched(task, firstTime.getTime(), -period);
    }

	//注意这个第二个参数是延迟，它会取当前时间，然后再延迟，并且周期取的相反数
	public void schedule(TimerTask task, long delay, long period) {
        if (delay < 0)
            throw new IllegalArgumentException("Negative delay.");
        if (period <= 0)
            throw new IllegalArgumentException("Non-positive period.");
        sched(task, System.currentTimeMillis()+delay, -period);
    }
	...重载的公共方法

内部真正实现的逻辑：
	
	/*这个方法最主要的就是把timerTask放到queue队列中去，并且设置一些初始状态周期等*/
    private void sched(TimerTask task, long time, long period) {
        if (time < 0)
            throw new IllegalArgumentException("Illegal execution time.");

        // Constrain value of period sufficiently to prevent numeric
        // overflow while still being effectively infinitely large.
        if (Math.abs(period) > (Long.MAX_VALUE >> 1))
            period >>= 1;

        synchronized(queue) {
            if (!thread.newTasksMayBeScheduled)
                throw new IllegalStateException("Timer already cancelled.");

            synchronized(task.lock) {
                if (task.state != TimerTask.VIRGIN)
                    throw new IllegalStateException(
                        "Task already scheduled or cancelled");
                task.nextExecutionTime = time;
                task.period = period;
                task.state = TimerTask.SCHEDULED;
            }

            queue.add(task);
            if (queue.getMin() == task)
                queue.notify();
        }
    }


> queue用来存放TimerTask
##TaskQueue
它是一个内部类，主要功能就是用来存放TimerTask，它的内部实现是一个队列，队列是自实现的，而不是java.util.下的队列实现。
内部实现细节来说，主要就是一个初始长度为128的TimerTask数组。并且提供一个add(TimerTask task)方法,clear方法，size()等方法。
	//这个是内部的队列
    class TaskQueue {
    /**
     * Priority queue represented as a balanced binary heap: the two children
     * of queue[n] are queue[2*n] and queue[2*n+1].  The priority queue is
     * ordered on the nextExecutionTime field: The TimerTask with the lowest
     * nextExecutionTime is in queue[1] (assuming the queue is nonempty).  For
     * each node n in the heap, and each descendant of n, d,
     * n.nextExecutionTime <= d.nextExecutionTime.
     */
    private TimerTask[] queue = new TimerTask[128];

    /**
     * The number of tasks in the priority queue.  (The tasks are stored in
     * queue[1] up to queue[size]).
     */
    private int size = 0;

    /**
     * Returns the number of tasks currently on the queue.
     */
    int size() {
        return size;
    }

    /**
     * Adds a new task to the priority queue.
     */
    void add(TimerTask task) {
        // Grow backing store if necessary
        if (size + 1 == queue.length)
            queue = Arrays.copyOf(queue, 2*queue.length);

        queue[++size] = task;//从下标1开始存的
        fixUp(size);
    }

	//如果
	private void fixUp(int k) {
        while (k > 1) {
            int j = k >> 1;
			//下次执行时间比较小的放在数组前边，因此这个timerTask数组是按下次执行时间进行排序的
            if (queue[j].nextExecutionTime <= queue[k].nextExecutionTime)
                break;
            TimerTask tmp = queue[j];  queue[j] = queue[k]; queue[k] = tmp;
            k = j;
        }
    }


> TimerThread 是真正执行任务的线程，它的定义是：
> 首先它是一个线程，然后它的run方法是一个while(true)的循环，因此这个线程启动之后会一直执行。直到调用停止方法来控制。
    
	class TimerThread extends Thread {
    /**
     * This flag is set to false by the reaper to inform us that there
     * are no more live references to our Timer object.  Once this flag
     * is true and there are no more tasks in our queue, there is no
     * work left for us to do, so we terminate gracefully.  Note that
     * this field is protected by queue's monitor!
     */
    boolean newTasksMayBeScheduled = true;

    /**
     * Our Timer's queue.  We store this reference in preference to
     * a reference to the Timer so the reference graph remains acyclic.
     * Otherwise, the Timer would never be garbage-collected and this
     * thread would never go away.
     */
    private TaskQueue queue;

    TimerThread(TaskQueue queue) {
        this.queue = queue;
    }

    public void run() {
        try {
            mainLoop();
        } finally {
            // Someone killed this Thread, behave as if Timer cancelled
            synchronized(queue) {
                newTasksMayBeScheduled = false;
                queue.clear();  // Eliminate obsolete references
            }
        }
    }

    /**
     * The main timer loop.  (See class comment.)
     */
    private void mainLoop() {
        while (true) {
            try {
                TimerTask task;
                boolean taskFired;
                synchronized(queue) {
                    // Wait for queue to become non-empty
                    while (queue.isEmpty() && newTasksMayBeScheduled)
                        queue.wait();
                    if (queue.isEmpty())//如果空的话，前面就不会退出while。
                        break; // Queue is empty and will forever remain; die

                    // Queue nonempty; look at first evt and do the right thing
                    long currentTime, executionTime;
                    task = queue.getMin();//return queue[1]
                    synchronized(task.lock) {
                        if (task.state == TimerTask.CANCELLED) {
                            queue.removeMin();//已取消的任务不会执行，并且把它从队列中移除
                            continue;  // No action required, poll queue again
                        }
                        currentTime = System.currentTimeMillis();
                        executionTime = task.nextExecutionTime;
                        if (taskFired = (executionTime<=currentTime)) {//已经执行过
                            if (task.period == 0) { // Non-repeating, remove
                                queue.removeMin();//非周期的就要移除
                                task.state = TimerTask.EXECUTED;
                            } else { // Repeating task, reschedule
								//周期的要设置下一次执行的时间
                                queue.rescheduleMin(
                                  task.period<0 ? currentTime   - task.period
                                                : executionTime + task.period);
                            }
                        }
                    }
                    if (!taskFired) // Task hasn't yet fired; wait
                        queue.wait(executionTime - currentTime);//等待一段时间，超时后自动被唤醒，然后竞争获得锁后再执行下面的步骤
						为啥我感觉要用sleep呢。。。，我觉得不用sleep是为了让这个queue能更多的被其他线程访问，这个我能理解。然后又因为其他线程中没有使用notify通知，所以这个wait永远都不会因为收到notify而提前结束等待，每次都会是等待超时然后进入竞争锁的队列，这样的话就相当于sleep的效果了。---这个时间不精准的，如果恰好不准确，也有可能一直都执行不下去啊。开始执行的时间就不对，当然这个是极端的情况	
                }
				//这里没有持有锁的，因为已经不需要了，直接让task执行就行了。
                if (taskFired)  // Task fired; run it, holding no locks
                    task.run();
            } catch(InterruptedException e) {
            }
        }
    }
}


# TimerTask类 #
public abstract class TimerTask implements Runnable
它是一个抽象类，实现了Runnable接口，但是该类没有实现run方法，因此具体的TimerTask类要实现自己的run方法。

实例变量：

    final Object lock = new Object();

    /**
     * The state of this task, chosen from the constants below.
     */
    int state = VIRGIN;

    /**
     * This task has not yet been scheduled.
     */
    static final int VIRGIN = 0;

    /**
     * This task is scheduled for execution.  If it is a non-repeating task,
     * it has not yet been executed.
     */
    static final int SCHEDULED   = 1;

    /**
     * This non-repeating task has already executed (or is currently
     * executing) and has not been cancelled.
     */
    static final int EXECUTED    = 2;

    /**
     * This task has been cancelled (with a call to TimerTask.cancel).
     */
    static final int CANCELLED   = 3;
> 上面的都是实例变量，主要是一个锁和标记当前任务的状态变量。

    /**
     * Next execution time for this task in the format returned by
     * System.currentTimeMillis, assuming this task is scheduled for execution.
     * For repeating tasks, this field is updated prior to each task execution.
     */
    long nextExecutionTime;//下次执行时间，周期任务会每次更新

    /**
     * Period in milliseconds for repeating tasks.  A positive value indicates
     * fixed-rate execution.  A negative value indicates fixed-delay execution.
     * A value of 0 indicates a non-repeating task.
     */
    long period = 0;


重要方法：
	//这个会将当前任务标记为CANCELLED状态
	public boolean cancel() {
        synchronized(lock) {
            boolean result = (state == SCHEDULED);
            state = CANCELLED;
            return result;
        }
    }

	//计算下一次执行的时间
	public long scheduledExecutionTime() {
        synchronized(lock) {
            return (period < 0 ? nextExecutionTime + period
                               : nextExecutionTime - period);
        }
    }
