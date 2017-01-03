# BlockingQueue 阻塞队列接口 #

查看类声明和API描述：

public interface BlockingQueue<E> extends Queue<E>

> 阻塞队列是支持两个附加操作的队列，这两个操作是：获取元素时等待队列变为非空，以及存储元素时等待空间变得可用。
> 
> BlockingQueue 方法以四种形式出现，对于不能立即满足但可能在将来某一时刻可以满足的操作，这四种形式的处理方式不同：第一种是抛出一个异常，第二种是返回一个特殊值（null 或 false，具体取决于操作），第三种是在操作可以成功前，无限期地阻塞当前线程，第四种是在放弃前只在给定的最大时间限制内阻塞。

这4种操作整理如下：
	
		抛出异常		特殊值		阻塞		超时
	插入	add(e)		offer(e)	put(e)	offer(e, time, unit)
	移除	remove()	poll()		take()	poll(time, unit)
	检查	element()	peek()		不可用	不可用

> 上面的操作，针对插入举例：
> 如果使用add方法插入元素，这个时候队列满了，那么add方法会抛异常。如果使用offer操作插入元素，如果队列满了，那么会返回false，插入不成功。如果使用put方法，如果队列满，那么这个put会一直等待，直到队列有位置可以插入。如果使用offer(e,time),如果队列满了，那么这个方法会等待指定的时间，这段时间内，如果队列有空闲，那么就可以插入。超过这段时间，这个值就会被丢弃，不会插入到队列中。

这个主要就是用于生产者--消费者队列。


----------
方法：
    
	/**
     * Returns the number of additional elements that this queue can ideally
     * (in the absence of memory or resource constraints) accept without
     * blocking, or <tt>Integer.MAX_VALUE</tt> if there is no intrinsic
     * limit.
     *
     * <p>Note that you <em>cannot</em> always tell if an attempt to insert
     * an element will succeed by inspecting <tt>remainingCapacity</tt>
     * because it may be the case that another thread is about to
     * insert or remove an element.
     *
     * @return the remaining capacity
     */
    int remainingCapacity();//剩余容量，值得注意的是，如果没有指定队列容量的话，这个方法会一直返回剩余容量是MAX INTEGER,而不是实际可插入的容量。


----------

## ArrayBlockingQueue 类 ##
类的声明：

public class ArrayBlockingQueue<E> extends AbstractQueue<E>
        implements BlockingQueue<E>, java.io.Serializable 
API描述：
> 一个由数组支持的有界阻塞队列。此队列按 FIFO（先进先出）原则对元素进行排序。队列的头部 是在队列中存在时间最长的元素。队列的尾部 是在队列中存在时间最短的元素。新元素插入到队列的尾部，队列获取操作则是从队列头部开始获得元素。
> 
这是一个典型的“有界缓存区”，固定大小的数组在其中保持生产者插入的元素和使用者提取的元素。一旦创建了这样的缓存区，就不能再增加其容量。试图向已满队列中放入元素会导致操作受阻塞；试图从空队列中提取元素将导致类似阻塞。

> 此类支持对等待的生产者线程和使用者线程进行排序的可选公平策略。默认情况下，不保证是这种排序。然而，通过将公平性 (fairness) 设置为 true 而构造的队列允许按照 FIFO 顺序访问线程。公平性通常会降低吞吐量，但也减少了可变性和避免了“不平衡性”


----------
具体的变量和方法：


	1.数组中元素的基本属性：
    /** The queued items */
    final Object[] items;
	/** items index for next take, poll, peek or remove */
    int takeIndex;

    /** items index for next put, offer, or add */
    int putIndex;

    /** Number of elements in the queue */
    int count;

    2.并发控制用到的锁与条件
	/** Main lock guarding all access */
    final ReentrantLock lock;

    /** Condition for waiting takes */
    private final Condition notEmpty;

    /** Condition for waiting puts */
    private final Condition notFull;


----------
滚回去看Lock相关的了。不然看不懂

