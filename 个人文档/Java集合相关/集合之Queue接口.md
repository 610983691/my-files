# Queue队列接口 #
查看类的声明和相关的API描述：

public interface Queue<E> extends Collection<E>

它继承了Collection的方法，并且提供了额外的队列操作方法，包括插入、移除和查找。每个方法提供两种形式一种抛异常，一种不抛异常。


----------


# Deque 双端队列接口 #

类的声明：
public interface Deque<E> extends  Queue<E>

它在Queue接口上扩展了如下方法：

**first **last方法

**官方的API说明如下：**

> 一个线性 collection，支持在两端插入和移除元素。名称 deque 是“double ended queue（双端队列）”的缩写，通常读为“deck”。大多数 Deque 实现对于它们能够包含的元素数没有固定限制，但此接口既支持有容量限制的双端队列，也支持没有固定大小限制的双端队列。
> 
此接口定义在双端队列两端访问元素的方法。提供插入、移除和检查元素的方法。每种方法都存在两种形式：一种形式在操作失败时抛出异常，另一种形式返回一个特殊值（null 或 false，具体取决于操作）。插入操作的后一种形式是专为使用有容量限制的 Deque 实现设计的；在大多数实现中，插入操作不能失败。



----------
## Queue的实现类如下：

##AbstractQueue类

类声明和API文档描述：
public abstract class AbstractQueue<E>
    extends AbstractCollection<E>
    implements Queue<E> {

> 此类提供某些 Queue 操作的骨干实现。看下已实现的方法：

    public boolean add(E e) {//这个方法是实现抽象集合类，它改为调用队列的offer
        if (offer(e))
            return true;
        else
            throw new IllegalStateException("Queue full");
    }
	public E remove() {//移除队首
        E x = poll();
        if (x != null)
            return x;
        else
            throw new NoSuchElementException();
    }
	public void clear() {
        while (poll() != null)//一直移除队首
            ;
    }
	//把集合中的元素添加到这个队列里面去
	public boolean addAll(Collection<? extends E> c) {
        if (c == null)
            throw new NullPointerException();
        if (c == this)
            throw new IllegalArgumentException();
        boolean modified = false;
        for (E e : c)
            if (add(e))
                modified = true;
        return modified;
    }

我的理解：这个抽象类就是为了将集合中对一般列表的 操作方法，改为对应的队列操作实现。这样，所有继承自这个抽象类的具体实现都可以实现对队列的操作，而不会发生误操作。
