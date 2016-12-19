# 集合之List接口 #
> 之前简单的整理了下Collection接口和子接口，现在就Collection下最常用的List接口以及下属的子类，抽象类进行学习。

首先说明：接口中的方法都还比较简单明了，具体有疑问可以查看API。当然，对有些接口和父接口相比较，对下层的实现提出了不同的规范与建议。

接下来就对集合框架中它的所有子类进行分析学习。

### 下面是Collection的实现类，包括抽象类，具体代码还是看源码，下面只是一些比较有意思的方法整理。
######看源码的时候发现，其实集合的操作还是对基本的数组进行了封装。如果自己要去实现基本的add,remove操作，还是得用到数组。所以别个说数据结构和算法是程序的根本呀，不管什么语言。

**public abstract class *AbstractList*<E> extends AbstractCollection<E> implements List<E>** 
   
	 这个抽象类对add()方法，set()方法也是没有提供具体的实现的。
	同时值得注意的是iterator和listIterator方法：
	iterator()方法返回的是一个私有的内部类实例Itr,Itr实现了Iterator接口。在内部类Itr中，实现了Iterator接口。
	这里我就在想，为啥要用一个私有的内部类来做一个迭代器返回呢？我能想到的有下面几点：
	1.因为迭代器的功能是要返回集合中的元素，所以它应当是与当前集合强相关的。因此写在内部。
	2.迭代器私有化是为了避免外部直接实例化。

	listIterator()方法返回一个ListItr的实例，这个实例也是私有的内部类。定义如下：
	private class ListItr extends Itr implements ListIterator<E>
	这个类继承了Itr类，同时增加了listIterator所需的set(),previous()等方法。

	此外AbstractList还提供了SubList<E> 方法。
	public List<E> subList(int fromIndex, int toIndex) {
        return (this instanceof RandomAccess ?
                new RandomAccessSubList<>(this, fromIndex, toIndex) :
                new SubList<>(this, fromIndex, toIndex));
    }
	这个随机访问与否可以看具体的list类是否实现了RandomAcess接口。而SubList又是AbstractList的内部类，它的构造方法：
	class SubList<E> extends AbstractList<E> {
	    private final AbstractList<E> l;
	    private final int offset;
	    private int size;
		SubList(AbstractList<E> list, int fromIndex, int toIndex) {
	        if (fromIndex < 0)
	            throw new IndexOutOfBoundsException("fromIndex = " + fromIndex);
	        if (toIndex > list.size())
	            throw new IndexOutOfBoundsException("toIndex = " + toIndex);
	        if (fromIndex > toIndex)
	            throw new IllegalArgumentException("fromIndex(" + fromIndex +
	                                               ") > toIndex(" + toIndex + 				")");
	        l = list；//引用指向传入的list
	        offset = fromIndex;//修改起始下标
	        size = toIndex - fromIndex;//修改size
	        this.modCount = l.modCount;
	    }
		//....其他方法
	}

----------
	而随机访问list的迭代器就是完全继承的父类SubList的构造方法。
    class RandomAccessSubList<E> extends SubList<E> implements RandomAccess {
    RandomAccessSubList(AbstractList<E> list, int fromIndex, int toIndex) {
        super(list, fromIndex, toIndex);
    }

    public List<E> subList(int fromIndex, int toIndex) {
        return new RandomAccessSubList<>(this, fromIndex, toIndex);
    }
    }


----------
**public abstract class AbstractSequentialList<E> extends  AbstractList<E>**

API描述;此类提供了 List 接口的骨干实现,从而最大限度地减少了实现受“连续访问”数据存储（如链接列表）支持的此接口所需的工作。对于随机访问数据（如数组），应该优先使用 AbstractList，而不是先使用此类。这个类作为链表类的超类。

需要注意的是，该类对listIterator和iterator方法进行了重写。如下：
    
	public Iterator<E> iterator() {
        return listIterator();
    }
	public abstract ListIterator<E> listIterator(int index);
这个应该就是为了实现连续访问机制而进行的修改，同时它也重写了add,get,set,remove等方法。具体就不赘述，可直接查看源码。


----------
好了，接下来就是天天都在用的ArrayList类了。

**public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable**


首先看类的声明：
> 
1.实现RandomAccess接口，说明该List是基于随机访问机制的。
2.序列化接口，实现接口可以将该类按照流方式写入文件，数据库，socket通讯等。
3.继承AbstractList中的方法，实现List接口。

再看变量声明和定义：
    
	private static final long serialVersionUID = 8683452581122892189L;

	/**
	 * Default initial capacity.
	 */
	private static final int DEFAULT_CAPACITY = 10;//初始容量
	private static final Object[] EMPTY_ELEMENTDATA = {};//空list的共享实例
	private transient Object[] elementData; //保存元素的数组
	private int size;//数组中元素个数

这里对transient关键字做个说明。该关键字的作用就是，它声明的变量不会被序列化。就是说如果将这个类的实例写入文件，会发现，transient关键字所修饰的变量不会被写入文件。

构造方法：
    
	public ArrayList(int initialCapacity) {
		super();
		if (initialCapacity < 0)
			throw new IllegalArgumentException(
					"Illegal Capacity: " + initialCapacity);
		this.elementData = new Object[initialCapacity];
	}
	public ArrayList() {
		super();
		this.elementData = EMPTY_ELEMENTDATA;
	}
	public ArrayList(Collection<? extends E> c) {
		elementData = c.toArray(); //集合对应的数组
		size = elementData.length; //修改size
		// c.toArray might (incorrectly) not return Object[] (see 6260652)
		if (elementData.getClass() != Object[].class)
			elementData = Arrays.copyOf(elementData, size, Object[].class);
	}
	对上面3个构造方法，需要说明的是：
	构造方法里边的super()方法就是指父类AbstractList的构造方法，它构造了一个空的AbstractList对象。
	同时，按照集合规范，ArrayList提供了一个无参和一个带参数的构造方法。它们分别制定初始容量，或者是直接生成一个空的数组。
	最后一个构造方法很直接，将集合转换为对应的ArrayList。这里有个bug 6260652,这个是为了防止子类向上转型之后，又将父类的对象放到list中去报错。(因为list里边的数组元素都是子类的实例，如果这个时候放一个父类的实例进去，肯定会报错)。具体还是参考官网的bugid.

下面是ArrayList的成员方法：
    
	public void trimToSize() {
		modCount++;
		if (size < elementData.length) {
			//list中数组长度改为实际的长度。
			elementData = Arrays.copyOf(elementData, size);
		}
	}

----------

	/**
	 * Increases the capacity of this <tt>ArrayList</tt> instance, if necessary,
	 * to ensure that it can hold at least the number of elements specified by
	 * the minimum capacity argument.
	 *
	 * @param minCapacity
	 *            the desired minimum capacity
	 */
	public void ensureCapacity(int minCapacity) {
		int minExpand = (elementData != EMPTY_ELEMENTDATA)
				// any size if real element table
				? 0
				// larger than default for empty table. It's already supposed to
				// be
				// at default size.
				: DEFAULT_CAPACITY;
		//最小扩展，空数组是10，有元素的最小扩展可以为0.表示容量足够的话可以不用扩展
		if (minCapacity > minExpand) {
			ensureExplicitCapacity(minCapacity);
		}
	}

	//自己对这个ensureCapacity(int capacity)方法进行测试。
	/*ArrayList<String> list = new ArrayList<String>();
		list.ensureCapacity(9);//这一步执行后还是空数组，并没有确保9个数组的容量啊。
		list.add("1");//这里能添加成功，也是因为add方法里面重新调用了ensureCapacity方法。
	*/
	//所以我感觉，这个方法感觉怪怪的。或者说，应该是我还没理解透这个EMPTY_ELEMENTDATA的精妙所在。。
	private void ensureExplicitCapacity(int minCapacity) {
		modCount++;
		//minCapacity比数组当前长度还长的话，就需要增加容量，否则不增加。
		//因此这里我感觉modCount++应该放在if里边？
		// overflow-conscious code
		if (minCapacity - elementData.length > 0)
			grow(minCapacity);
	}

	/**
	 * The maximum size of array to allocate. Some VMs reserve some header words
	 * in an array. Attempts to allocate larger arrays may result in
	 * OutOfMemoryError: Requested array size exceeds VM limit
	 */
	private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

	/**
	 * Increases the capacity to ensure that it can hold at least the number of
	 * elements specified by the minimum capacity argument.
	 *
	 * @param minCapacity
	 *            the desired minimum capacity
	 */
	private void grow(int minCapacity) {
		// overflow-conscious code
		int oldCapacity = elementData.length;
		//1.首先将当前elementData的容量指定为旧容量的1.5倍（是这个意思）。
		int newCapacity = oldCapacity + (oldCapacity >> 1);
		//2.如果新的容量比指定的最小容量还要小，就将新容量 指定为传入的参数大小。
		if (newCapacity - minCapacity < 0)
			newCapacity = minCapacity;
		//3.如果新容量比（MAX_ARRAY_SIZE）还大，就需要做特殊处理，就是hugeCapacity方法
		if (newCapacity - MAX_ARRAY_SIZE > 0)
			newCapacity = hugeCapacity(minCapacity);
		// minCapacity is usually close to size, so this is a win:
		elementData = Arrays.copyOf(elementData, newCapacity);
	}
	
	//作用：如果为负数，抛出错误。否则返回Integer.MAX_VALUE或者Integer.MAX_VALUE-8
	private static int hugeCapacity(int minCapacity) {
		if (minCapacity < 0) // overflow
			throw new OutOfMemoryError();
		return (minCapacity > MAX_ARRAY_SIZE)
				? Integer.MAX_VALUE
				: MAX_ARRAY_SIZE;
	}

	//这个嘛，
	private void ensureCapacityInternal(int minCapacity) {
		if (elementData == EMPTY_ELEMENTDATA) {
			minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
		}

		ensureExplicitCapacity(minCapacity);
	}

>接口描述对ensureCapacity（int ）的说法是：如果有必要，增加此 ArrayList 实例的容量，来确保它至少能够容纳minCapacity 参数所指定的元素数。
>
grow(minCapacity)方法：将数组容量增长为当前数组容量的1.5倍与minCapacity中的较大值。


----------
    public int size() {
		return size;
	}
	public boolean isEmpty() {
		return size == 0;
	}
	public boolean contains(Object o) {
		return indexOf(o) >= 0;
	}
	
	/**
	 * Returns the index of the first occurrence of the specified element in
	 * this list, or -1 if this list does not contain the element. More
	 * formally, returns the lowest index <tt>i</tt> such that
	 * <tt>(o==null&nbsp;?&nbsp;get(i)==null&nbsp;:&nbsp;o.equals(get(i)))</tt>,
	 * or -1 if there is no such index.
	 */
	public int indexOf(Object o) {
		if (o == null) {
			//要注意的是，这里是i<size,而不是i<elements.length
			for (int i = 0; i < size; i++)
				if (elementData[i] == null)
					return i;
		} else {
			for (int i = 0; i < size; i++)
				//如果没有重写equals,那么它只是比较两个对象的引用是否相等
				if (o.equals(elementData[i]))
					return i;
		}
		return -1;
	}
前面三个方法都很简单，来看看indexOf(Object o)方法。
首先它允许传入一个null对象，并且找到数组中第一个null,然后返回下标值。
如果不是null值的话，判断想等是用的Object.equals()方法。所以，按照Object规范，重写equals方法是很重要的。

---你看看人家String和Integer这些都老老实实的重写了equals方法的。

    /**
	 * Returns the index of the last occurrence of the specified element in this
	 * list, or -1 if this list does not contain the element. More formally,
	 * returns the highest index <tt>i</tt> such that
	 * <tt>(o==null&nbsp;?&nbsp;get(i)==null&nbsp;:&nbsp;o.equals(get(i)))</tt>,
	 * or -1 if there is no such index.
	 */
	public int lastIndexOf(Object o) {
		if (o == null) {
			for (int i = size - 1; i >= 0; i--)
				if (elementData[i] == null)
					return i;
		} else {
			for (int i = size - 1; i >= 0; i--)
				if (o.equals(elementData[i]))
					return i;
		}
		return -1;
	}

这个方法就不多说了，就是反向的查找object对象，并且返回一个下标值。

----------
	/**
	 * Returns a shallow copy of this <tt>ArrayList</tt> instance. (The elements
	 * themselves are not copied.)
	 *
	 * @return a clone of this <tt>ArrayList</tt> instance
	 */
	public Object clone() {
		try {
			@SuppressWarnings("unchecked")
			ArrayList<E> v = (ArrayList<E>) super.clone();
			v.elementData = Arrays.copyOf(elementData, size);
			v.modCount = 0;
			return v;
		} catch (CloneNotSupportedException e) {
			// this shouldn't happen, since we are Cloneable
			throw new InternalError();
		}
	}
> clone()方法是重写了Object.clone();根据API描述，这个clone()方法是一个浅拷贝。这就意味着，这个拷贝的副本与原list完全相等，对这个拷贝结果的所有操作都会影响到原有的list.（这个就像是给当前对象重新起个名字，这两个名字都指向当前的对象）
> 
> 同时也说一下深度拷贝，深度拷贝就是拷贝返回的对象值与原有的对象完全相等，但是，这个是两个完全不同的对象，它们各自的操作都不会影响到彼此的值。深度拷贝是要花时间的，即对象里边的每个成员变量你都要重新去new一份，然后放到拷贝里边去，所以说是要深层次的做拷贝动作一直到基本数据类型那一层。--这也就是"深"的意义所在。
> 
同时，protected方法是默认子类可看的，但是需要注意，只能在继承了父类的类的内部才能调用。这个很特别，需要注意。例如：ArrayList类，就算不重写clone方法，你在ArrayList类的任何一个方法里边都可以使用this.clone调用父类Objectclone方法。但是在一个普通类ClassA类里面的方法中，你使用list.clone()是无效的操作（假如ArrayList不重写clone的情况下），会编译报错。对于其他任何的类也是这样的。这点很重要，之前一直没注意，一直觉得只要子类继承了就可以使用，实际上还是要看子类实例所在的类是否和Object在同一个包下。显然，外部的程序都不可能和Object在同一个包下，所以这个clone方法是不得行的。

----------
    /**
	 * Returns an array containing all of the elements in this list in proper
	 * sequence (from first to last element).
	 *
	 * <p>
	 * The returned array will be "safe" in that no references to it are
	 * maintained by this list. (In other words, this method must allocate a new
	 * array). The caller is thus free to modify the returned array.
	 *
	 * <p>
	 * This method acts as bridge between array-based and collection-based APIs.
	 *
	 * @return an array containing all of the elements in this list in proper
	 *         sequence
	 */
	public Object[] toArray() {
		return Arrays.copyOf(elementData, size);
	}

	/**
	 * Returns an array containing all of the elements in this list in proper
	 * sequence (from first to last element); the runtime type of the returned
	 * array is that of the specified array. If the list fits in the specified
	 * array, it is returned therein. Otherwise, a new array is allocated with
	 * the runtime type of the specified array and the size of this list.
	 *
	 * <p>
	 * If the list fits in the specified array with room to spare (i.e., the
	 * array has more elements than the list), the element in the array
	 * immediately following the end of the collection is set to <tt>null</tt>.
	 * (This is useful in determining the length of the list <i>only</i> if the
	 * caller knows that the list does not contain any null elements.)
	 *
	 * @param a
	 *            the array into which the elements of the list are to be
	 *            stored, if it is big enough; otherwise, a new array of the
	 *            same runtime type is allocated for this purpose.
	 * @return an array containing the elements of the list
	 * @throws ArrayStoreException
	 *             if the runtime type of the specified array is not a supertype
	 *             of the runtime type of every element in this list
	 * @throws NullPointerException
	 *             if the specified array is null
	 */
	@SuppressWarnings("unchecked")
	public <T> T[] toArray(T[] a) {
		if (a.length < size)
			// Make a new array of a's runtime type, but my contents:
			return (T[]) Arrays.copyOf(elementData, size, a.getClass());
		System.arraycopy(elementData, 0, a, 0, size);
		if (a.length > size)
			a[size] = null;
		return a;
	}

> 上面两个方法是将ArrayList转为对应的数组形式。这两个方法之后看Arrays类再分析吧，这个暂时放下。


----------
	//需要注意的是这个方法的访问权限是包级私有的。
	E elementData(int index) {
		return (E) elementData[index];
	}
	//返回指定下标位置的元素。
	public E get(int index) {
		rangeCheck(index);

		return elementData(index);
	}
	/**
	 * Replaces the element at the specified position in this list with the
	 * specified element.
	 *
	 * @param index
	 *            index of the element to replace
	 * @param element
	 *            element to be stored at the specified position
	 * @return the element previously at the specified position
	 * @throws IndexOutOfBoundsException
	 *             {@inheritDoc}
	 */
	public E set(int index, E element) {
		rangeCheck(index);

		E oldValue = elementData(index);//需要注意的是，它会返回一个原位置的元素
		elementData[index] = element;
		return oldValue;
	}
	
	同时，这这里就把上面方法中的rangeCheck(index)就一并说了，这个方法的作用就是做数组越界检查。越界时会抛出异常.如下:

	/**
	 * Checks if the given index is in range. If not, throws an appropriate
	 * runtime exception. This method does *not* check if the index is negative:
	 * It is always used immediately prior to an array access, which throws an
	 * ArrayIndexOutOfBoundsException if index is negative.
	 */
	private void rangeCheck(int index) {
		if (index >= size)
			throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
	}

	/**
	 * A version of rangeCheck used by add and addAll.
	 */
	private void rangeCheckForAdd(int index) {
		if (index > size || index < 0)
			throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
	}

	/**
	 * Constructs an IndexOutOfBoundsException detail message. Of the many
	 * possible refactorings of the error handling code, this "outlining"
	 * performs best with both server and client VMs.
	 */
	private String outOfBoundsMsg(int index) {
		return "Index: " + index + ", Size: " + size;
	}

----------
    public boolean add(E e) {
		ensureCapacityInternal(size + 1); // Increments modCount!!
		elementData[size++] = e;
		return true;
	}

	/**
	 * Inserts the specified element at the specified position in this list.
	 * Shifts the element currently at that position (if any) and any subsequent
	 * elements to the right (adds one to their indices).
	 *
	 * @param index
	 *            index at which the specified element is to be inserted
	 * @param element
	 *            element to be inserted
	 * @throws IndexOutOfBoundsException
	 *             {@inheritDoc}
	 */
	public void add(int index, E element) {
		rangeCheckForAdd(index);

		ensureCapacityInternal(size + 1); // Increments modCount!!
		//这个方法就是从源数组目标位置开始，复制所有元素到目标数组的目标位置(循环的往后copy)，元素个数是size-index.--这步操作过后，index位置在 数组中就被空出来了。
		System.arraycopy(elementData, index, elementData, index + 1,
				size - index);
		elementData[index] = element;
		size++;
	}

----------
下面是remove方法：

	/**
	 * Removes the element at the specified position in this list. Shifts any
	 * subsequent elements to the left (subtracts one from their indices).
	 *
	 * @param index
	 *            the index of the element to be removed
	 * @return the element that was removed from the list
	 * @throws IndexOutOfBoundsException
	 *             {@inheritDoc}
	 */
	
	public E remove(int index) {
		rangeCheck(index);//边界检查

		modCount++;
		E oldValue = elementData(index);、、

		int numMoved = size - index - 1;
		if (numMoved > 0)
			System.arraycopy(elementData, index + 1, elementData, index,
					numMoved);
		elementData[--size] = null; // clear to let GC do its work

		return oldValue;
	}

	/**
	 * Removes the first occurrence of the specified element from this list, if
	 * it is present. If the list does not contain the element, it is unchanged.
	 * More formally, removes the element with the lowest index <tt>i</tt> such
	 * that
	 * <tt>(o==null&nbsp;?&nbsp;get(i)==null&nbsp;:&nbsp;o.equals(get(i)))</tt>
	 * (if such an element exists). Returns <tt>true</tt> if this list contained
	 * the specified element (or equivalently, if this list changed as a result
	 * of the call).
	 *
	 * @param o
	 *            element to be removed from this list, if present
	 * @return <tt>true</tt> if this list contained the specified element
	 */
	public boolean remove(Object o) {
		if (o == null) {
			for (int index = 0; index < size; index++)
				if (elementData[index] == null) {
					fastRemove(index);
					return true;
				}
		} else {
			for (int index = 0; index < size; index++)
				if (o.equals(elementData[index])) {
					fastRemove(index);
					return true;
				}
		}
		return false;
	}

	/*
	 * Private remove method that skips bounds checking and does not return the
	 * value removed.
	 */
	//快速删除，它不做边界检查，不用保存返回的对象。因此只需要对数组copy覆盖操作，
	//并把最后一个位置的元素置为空
	private void fastRemove(int index) {
		modCount++;
		int numMoved = size - index - 1;
		if (numMoved > 0)
			System.arraycopy(elementData, index + 1, elementData, index,
					numMoved);
		elementData[--size] = null; // clear to let GC do its work
	}



> 这个方法remove()需要注意的是，如果是一个ArrayList<Integer>,那么remove(Integer a )的时候，它会默认先调用remove(Object o)而不是remove(int index)。因为它认为a这个时候是一个对象，而不是一个int值。


----------
    /**
	 * Removes all of the elements from this list. The list will be empty after
	 * this call returns.
	 */
	public void clear() {
		modCount++;

		// clear to let GC do its work
		//我觉得不直接将elementData=EMPTY_ELEMENT,是因为必须将elementData中的元素置为空，否则GC不会回收这些元素，造成内存泄漏。
		for (int i = 0; i < size; i++)
			elementData[i] = null;

		size = 0;
	}

----------
    public boolean addAll(Collection<? extends E> c) {
		Object[] a = c.toArray();
		int numNew = a.length;
		ensureCapacityInternal(size + numNew); // Increments modCount
		System.arraycopy(a, 0, elementData, size, numNew);//复制到elementData的末尾
		size += numNew;
		return numNew != 0;
	}
	public boolean addAll(int index, Collection<? extends E> c) {
		rangeCheckForAdd(index);

		Object[] a = c.toArray();
		int numNew = a.length;
		ensureCapacityInternal(size + numNew); // Increments modCount

		int numMoved = size - index;
		if (numMoved > 0)//如果是在中间插入，就先将当前的数组在index这个位置腾numNew个位置给a[]
			System.arraycopy(elementData, index, elementData, index + numNew,
					numMoved);

		System.arraycopy(a, 0, elementData, index, numNew);
		size += numNew;
		return numNew != 0;
	}
	注意返回值，插入的数量只要不为0就会返回一个true,否则返回false.

----------
    /**
	 * Removes from this list all of the elements whose index is between
	 * {@code fromIndex}, inclusive, and {@code toIndex}, exclusive. Shifts any
	 * succeeding elements to the left (reduces their index). This call shortens
	 * the list by {@code (toIndex - fromIndex)} elements. (If
	 * {@code toIndex==fromIndex}, this operation has no effect.)
	 *
	 * @throws IndexOutOfBoundsException
	 *             if {@code fromIndex} or {@code toIndex} is out of range (
	 *             {@code fromIndex < 0 ||
	 *          fromIndex >= size() ||
	 *          toIndex > size() ||
	 *          toIndex < fromIndex})
	 */
	//移除两个索引之间的元素，并且把后续的元素往前移。两个相等则操作无效。
	//注意它是一个protected方法
	protected void removeRange(int fromIndex, int toIndex) {
		modCount++;
		int numMoved = size - toIndex;
		System.arraycopy(elementData, toIndex, elementData, fromIndex,
				numMoved);

		// clear to let GC do its work
		int newSize = size - (toIndex - fromIndex);
		for (int i = newSize; i < size; i++) {
			elementData[i] = null;
		}
		size = newSize;
	}

----------
    public boolean removeAll(Collection<?> c) {
		return batchRemove(c, false);
	}
	public boolean retainAll(Collection<?> c) {
		return batchRemove(c, true);
	}
	private boolean batchRemove(Collection<?> c, boolean complement) {
		final Object[] elementData = this.elementData;
		int r = 0, w = 0;
		boolean modified = false;
		try {
			for (; r < size; r++)//只要list中的元素存在于c,就保存在elementData里面
				if (c.contains(elementData[r]) == complement)
					//决定是保留存在于c中还是不存在于c中的元素，根据complement判断
					elementData[w++] = elementData[r];//这里r>=w。w是保留的元素个数
		} finally {
			// Preserve behavioral compatibility with AbstractCollection,
			// even if c.contains() throws.
			if (r != size) {//说明try中抛了异常，把r后面的都接在w下标的后面.
				System.arraycopy(elementData, r, elementData, w, size - r);
				w += size - r;
			}
			if (w != size) {//保留的小于size说明才有改动
				// clear to let GC do its work
				for (int i = w; i < size; i++)//w是保留的元素，把w后面的都移除。
					elementData[i] = null;
				modCount += size - w;
				size = w;
				modified = true;
			}
		}
		return modified;
	}

----------
> 在里边还发现两个私有的 readObject()和writeObject()方法，也没看到有调用，干嘛的 ？
> 在网上看到是这样说的，先记下来：
> 
> 实现接口Serializable的方法.
在序列化和反序列化过程中需要特殊处理的类必须使用下列准确签名来实现特殊方法：
private void writeObject(java.io.ObjectOutputStream out)
throws IOException
private void readObject(java.io.ObjectInputStream in)
throws IOException, ClassNotFoundException;

----------
	/**
	 * Returns a list iterator over the elements in this list (in proper
	 * sequence), starting at the specified position in the list. The specified
	 * index indicates the first element that would be returned by an initial
	 * call to {@link ListIterator#next next}. An initial call to
	 * {@link ListIterator#previous previous} would return the element with the
	 * specified index minus one.
	 *
	 * <p>
	 * The returned list iterator is <a href="#fail-fast"><i>fail-fast</i></a>.
	 *
	 * @throws IndexOutOfBoundsException
	 *             {@inheritDoc}
	 */
	public ListIterator<E> listIterator(int index) {
		if (index < 0 || index > size)
			throw new IndexOutOfBoundsException("Index: " + index);
		return new ListItr(index);
	}
    /**
	 * Returns a list iterator over the elements in this list (in proper
	 * sequence).
	 *
	 * <p>
	 * The returned list iterator is <a href="#fail-fast"><i>fail-fast</i></a>.
	 *
	 * @see #listIterator(int)
	 */
	public ListIterator<E> listIterator() {
		return new ListItr(0);
	}

	/**
	 * Returns an iterator over the elements in this list in proper sequence.
	 *
	 * <p>
	 * The returned iterator is <a href="#fail-fast"><i>fail-fast</i></a>.
	 *
	 * @return an iterator over the elements in this list in proper sequence
	 */
	public Iterator<E> iterator() {
		return new Itr();
	}
> 上面两个方法是获取迭代器的方法，list内部都是使用内部类的方式来获取迭代器的。
私有化内部类保证不能被外部实例化，同时方法为public又保证可以被外部调用。
下面先来看下Itr这个私有内部类：

    /**
	 * An optimized version of AbstractList.Itr
	 */
	private class Itr implements Iterator<E> {
		int cursor; // index of next element to return
		int lastRet = -1; // index of last element returned; -1 if no such
		int expectedModCount = modCount;

		public boolean hasNext() {//游标指向的是下一个，数组下标最大为size-1
			return cursor != size;
		}

		@SuppressWarnings("unchecked")
		public E next() {//获取下一个元素
			checkForComodification();//检查list是否已经发生改变
			int i = cursor;
			if (i >= size)//越界检查
				throw new NoSuchElementException();
			Object[] elementData = ArrayList.this.elementData;//这里不能用this,this会被认为是Itr这个类的实例
			if (i >= elementData.length)//同样有可能发生改变
				throw new ConcurrentModificationException();
			cursor = i + 1;
			return (E) elementData[lastRet = i];//lastRet每次会被修改
		}

		public void remove() {
			if (lastRet < 0)//remove操作必须在next之后
				throw new IllegalStateException();
			checkForComodification();

			try {
				ArrayList.this.remove(lastRet);
				cursor = lastRet;
				lastRet = -1;
				expectedModCount = modCount;//重新指定它们相等，.this.remove(lastRet);会修改modCount
			} catch (IndexOutOfBoundsException ex) {
				throw new ConcurrentModificationException();
			}
		}
		//因为list每次被修改（add.set,remove等），modcount都会改变，因此这个操作可以判断在迭代的时候，这个list是否被修改了。自己测试也是这样的结果
		final void checkForComodification() {
			if (modCount != expectedModCount)
				throw new ConcurrentModificationException();
		}
	}

----------
listItr私有内部类：

    /**
	 * An optimized version of AbstractList.ListItr
	 */
	private class ListItr extends Itr implements ListIterator<E> {
		ListItr(int index) {
			super();
			cursor = index;
		}

		public boolean hasPrevious() {
			return cursor != 0;
		}

		public int nextIndex() {
			return cursor;
		}

		public int previousIndex() {
			return cursor - 1;
		}

		@SuppressWarnings("unchecked")
		public E previous() {
			checkForComodification();
			int i = cursor - 1;
			if (i < 0)
				throw new NoSuchElementException();
			Object[] elementData = ArrayList.this.elementData;
			if (i >= elementData.length)
				throw new ConcurrentModificationException();
			cursor = i;
			return (E) elementData[lastRet = i];
		}

		public void set(E e) {
			if (lastRet < 0)
				throw new IllegalStateException();
			checkForComodification();

			try {
				ArrayList.this.set(lastRet, e);
			} catch (IndexOutOfBoundsException ex) {
				throw new ConcurrentModificationException();
			}
		}

		public void add(E e) {
			checkForComodification();

			try {
				int i = cursor;
				ArrayList.this.add(i, e);
				cursor = i + 1;
				lastRet = -1;
				expectedModCount = modCount;
			} catch (IndexOutOfBoundsException ex) {
				throw new ConcurrentModificationException();
			}
		}
	}

> 需要注意的就是listItr是继承了Itr的，所以如果不想在迭代器中修改list并且只想向后遍历，那么只需要调用itr迭代器就行了。针对要在迭代的过程中对list进行add,remove,set等修改，就可以使用listIterator迭代器。


----------
最后，还有个SubList()方法，顾名思义，就是获取ArrayList的子列表。这个也是通过内部类来实现的。
    //返回一个子列表的实例。
	public List<E> subList(int fromIndex, int toIndex) {
		subListRangeCheck(fromIndex, toIndex, size);
		return new SubList(this, 0, fromIndex, toIndex);
	}

	private class SubList extends AbstractList<E> implements RandomAccess{}；

> 就不贴内部类的代码实现了，它继承了AbstractList类，因此也会实现add,set等方法，这些都差不多的。


----------
总结：ArrayList是随机访问，非线程安全。


----------
## 下面是LinkedList ##
前面一部分是ArrayList随机访问列表。下面分析下具体的LinkedList列表的实现。
首先是类的声明，这里摘抄一部分的API文档描述。

    public class LinkedList<E>
    extends AbstractSequentialList<E>
    implements List<E>, Deque<E>, Cloneable, java.io.Serializable

> List 接口的链接列表实现。实现所有可选的列表操作，并且允许所有元素（包括 null）。除了实现 List 接口外，LinkedList 类还为在列表的开头及结尾 get、remove 和 insert 元素提供了统一的命名方法。这些操作允许将链接列表用作堆栈、队列或双端队列。
> 注意，此实现不是同步的。

查看类的声明，实现了双端队列，序列化，同时继承Cloneable接口，List接口，连续访问的列表。


----------
字段的声明:
    transient int size = 0;

    /**
     * Pointer to first node.
     * Invariant: (first == null && last == null) ||
     *            (first.prev == null && first.item != null)
     */
    transient Node<E> first;

    /**
     * Pointer to last node.
     * Invariant: (first == null && last == null) ||
     *            (last.next == null && last.item != null)
     */
    transient Node<E> last;
	//需要注意的就是字段都是transient修饰的，并且都没有声明为private 这个是啥情况？难道util的其他类会用？

----------
构造方法：

     /**
     * Constructs an empty list.
     */
    public LinkedList() {
    }

    /**
     * Constructs a list containing the elements of the specified
     * collection, in the order they are returned by the collection's
     * iterator.
     *
     * @param  c the collection whose elements are to be placed into this list
     * @throws NullPointerException if the specified collection is null
     */
    public LinkedList(Collection<? extends E> c) {
        this();
        addAll(c);
    }
	//按照规范提供了一个空的构造方法和一个集合参数的构造方法。

----------
同时，由于LinkedList实现了链表，双端队列，Stack等功能。所以必须要先看看它的内部类：
    
	private static class Node<E> {
        E item;
        Node<E> next;
        Node<E> prev;

		//Node的构造方法
        Node(Node<E> prev, E element, Node<E> next) {
            this.item = element;
            this.next = next;
            this.prev = prev;
        }
    }

----------
下面是LinkedList的其他方法：
    
	/**
     * Links e as first element.把它作为链表的第一个节点
     */
    private void linkFirst(E e) {
        final Node<E> f = first;
        final Node<E> newNode = new Node<>(null, e, f);
        first = newNode;
        if (f == null)
            last = newNode;
        else
            f.prev = newNode;
        size++;
        modCount++;
    }

    /**
     * Links e as last element.作为最后一个节点
     */
    void linkLast(E e) {
        final Node<E> l = last;
        final Node<E> newNode = new Node<>(l, e, null);
        last = newNode;
        if (l == null)
            first = newNode;
        else
            l.next = newNode;
        size++;
        modCount++;
    }

    /**
     * Inserts element e before non-null Node succ.
     * 在节点succ的前面插入e节点
     */
    void linkBefore(E e, Node<E> succ) {
        // assert succ != null;
        final Node<E> pred = succ.prev;
        final Node<E> newNode = new Node<>(pred, e, succ);
        succ.prev = newNode;
        if (pred == null)
            first = newNode;
        else
            pred.next = newNode;
        size++;
        modCount++;
    }

----------
    /**
     * Unlinks non-null first node f.
     * 移除列表中第一个节点f.(这个是私有方法，非空判断在调用该方法之前已经做了)
     */
    private E unlinkFirst(Node<E> f) {
        // assert f == first && f != null;
        final E element = f.item;
        final Node<E> next = f.next;
        f.item = null;
        f.next = null; // help GC
        first = next;
        if (next == null)
            last = null;
        else
            next.prev = null;
        size--;
        modCount++;
        return element;
    }

    /**
     * Unlinks non-null last node l.
     */
    private E unlinkLast(Node<E> l) {
        // assert l == last && l != null;
        final E element = l.item;
        final Node<E> prev = l.prev;
        l.item = null;
        l.prev = null; // help GC
        last = prev;
        if (prev == null)
            first = null;
        else
            prev.next = null;
        size--;
        modCount++;
        return element;
    }

	 /**
     * Unlinks non-null node x.移除非空节点作为链表时使用
     */
    E unlink(Node<E> x) {
        // assert x != null;
        final E element = x.item;
        final Node<E> next = x.next;
        final Node<E> prev = x.prev;

        if (prev == null) {
            first = next;
        } else {
            prev.next = next;
            x.prev = null;
        }

        if (next == null) {
            last = prev;
        } else {
            next.prev = prev;
            x.next = null;
        }

        x.item = null;
        size--;
        modCount++;
        return element;
    }

----------
下面是链表常用的公共方法getFirst(),getLast()，addfirst,removefirst等方法：

	/**
     * Returns the first element in this list.
     *
     * @return the first element in this list
     * @throws NoSuchElementException if this list is empty
     */
    public E getFirst() {
        final Node<E> f = first;
        if (f == null)
            throw new NoSuchElementException();
        return f.item;
    }

    /**
     * Returns the last element in this list.
     *
     * @return the last element in this list
     * @throws NoSuchElementException if this list is empty
     */
    public E getLast() {
        final Node<E> l = last;
        if (l == null)
            throw new NoSuchElementException();
        return l.item;
    }

    /**
     * Removes and returns the first element from this list.
     *
     * @return the first element from this list
     * @throws NoSuchElementException if this list is empty
     */
    public E removeFirst() {
        final Node<E> f = first;
        if (f == null)
            throw new NoSuchElementException();
        return unlinkFirst(f);
    }

    /**
     * Removes and returns the last element from this list.
     *
     * @return the last element from this list
     * @throws NoSuchElementException if this list is empty
     */
    public E removeLast() {
        final Node<E> l = last;
        if (l == null)
            throw new NoSuchElementException();
        return unlinkLast(l);
    }

    /**
     * Inserts the specified element at the beginning of this list.
     *
     * @param e the element to add
     */
    public void addFirst(E e) {
        linkFirst(e);
    }

    /**
     * Appends the specified element to the end of this list.
     *
     * <p>This method is equivalent to {@link #add}.
     *
     * @param e the element to add
     */
    public void addLast(E e) {
        linkLast(e);
    }
	//上面这些操作都是通过调用私有的或者是包级私有的方法实现的，因为私有方法的操作在实现List接口的add()、set()、remove()方法中也会使用。

----------
下面是list接口中需要实现的add()/remove()/set()等方法。
    
	/**
     * Appends the specified element to the end of this list.
     *
     * <p>This method is equivalent to {@link #addLast}.
     *
     * @param e element to be appended to this list
     * @return {@code true} (as specified by {@link Collection#add})
     */
    public boolean add(E e) {
        linkLast(e);//添加时，默认加在list的尾部
        return true;
    }

	//移除list中的一个节点o,这个相等方法是用equals判断
	public boolean remove(Object o) {
        if (o == null) {//空值
            for (Node<E> x = first; x != null; x = x.next) {
                if (x.item == null) {
                    unlink(x);
                    return true;
                }
            }
        } else {
            for (Node<E> x = first; x != null; x = x.next) {
                if (o.equals(x.item)) {
                    unlink(x);
                    return true;
                }
            }
        }
        return false;
    }
	//添加一个集合到lsit中的尾部
	public boolean addAll(Collection<? extends E> c) {
        return addAll(size, c);
    }
	//在指定位置插入一个集合的所有元素，元素顺序是c.toArray()的顺序。
	public boolean addAll(int index, Collection<? extends E> c) {
        checkPositionIndex(index);//检查这个位置是不是存在

        Object[] a = c.toArray();
        int numNew = a.length;//插入数量
        if (numNew == 0)
            return false;

        Node<E> pred, succ;
        if (index == size) {
            succ = null;
            pred = last;
        } else {
            succ = node(index);
            pred = succ.prev;
        }

        for (Object o : a) {//循环插入
            @SuppressWarnings("unchecked") E e = (E) o;
            Node<E> newNode = new Node<>(pred, e, null);
            if (pred == null)
                first = newNode;
            else
                pred.next = newNode;
            pred = newNode;
        }

        if (succ == null) {
            last = pred;
        } else {
            pred.next = succ;
            succ.prev = pred;
        }

        size += numNew;
        modCount++;
        return true;
    }
	/**
     * Removes all of the elements from this list.
     * The list will be empty after this call returns.
     */
    public void clear() {
        // Clearing all of the links between nodes is "unnecessary", but:
        // - helps a generational GC if the discarded nodes inhabit
        //   more than one generation
        // - is sure to free memory even if there is a reachable Iterator
        for (Node<E> x = first; x != null; ) {//所有都清空，帮助GC回收
            Node<E> next = x.next;
            x.item = null;
            x.next = null;
            x.prev = null;
            x = next;
        }
        first = last = null;
        size = 0;
        modCount++;
    }
	 /**
     * Returns the element at the specified position in this list.
     *
     * @param index index of the element to return
     * @return the element at the specified position in this list
     * @throws IndexOutOfBoundsException {@inheritDoc}
     */
    public E get(int index) {
        checkElementIndex(index);
        return node(index).item;
    }
	public E set(int index, E element) {
        checkElementIndex(index);
        Node<E> x = node(index);//只需要修改节点的值，引用都不需要改
        E oldVal = x.item;
        x.item = element;
        return oldVal;
    }
	//在指定位置插入一个元素（节点）
	public void add(int index, E element) {
        checkPositionIndex(index);

        if (index == size)
            linkLast(element);
        else
            linkBefore(element, node(index));
    }
	//移除指定位置的元素
	public E remove(int index) {
        checkElementIndex(index);
        return unlink(node(index));
    }

	/**
     * Returns the (non-null) Node at the specified element index.
     * 这就是连续访问与随机访问的不同，如果是arrayList,知道索引的话，不需要遍历可以直接获取到对应位置的元素
     */
    Node<E> node(int index) {
        // assert isElementIndex(index);

        if (index < (size >> 1)) {//可以，避免每次都从列表最前面开始找，点赞
            Node<E> x = first;
            for (int i = 0; i < index; i++)
                x = x.next;
            return x;
        } else {
            Node<E> x = last;
            for (int i = size - 1; i > index; i--)
                x = x.prev;
            return x;
        }
    }
----------
查找方法：
    
	//查找o在列表中的位置，可为null.从里面两个循环可以知道，时间复杂度是o(l).
	public int indexOf(Object o) {
        int index = 0;
        if (o == null) {
            for (Node<E> x = first; x != null; x = x.next) {
                if (x.item == null)
                    return index;
                index++;
            }
        } else {
			
            for (Node<E> x = first; x != null; x = x.next) {
                if (o.equals(x.item))
                    return index;
                index++;
            }
        }
        return -1;
    }
	//反向查找
	 public int lastIndexOf(Object o) {
        int index = size;
        if (o == null) {
            for (Node<E> x = last; x != null; x = x.prev) {
                index--;
                if (x.item == null)
                    return index;
            }
        } else {
            for (Node<E> x = last; x != null; x = x.prev) {
                index--;
                if (o.equals(x.item))
                    return index;
            }
        }
        return -1;
    }
	//返回list中的第一个节点的元素
	 public E peek() {
        final Node<E> f = first;
        return (f == null) ? null : f.item;
    }
	//返回list中的第一个节点的元素，如果没会抛异常
	public E element() {
        return getFirst();
    }
> 其他还有些方法，都是双端队列、栈需要时间的pull/add方法，它们对查询null时有两种形式，一种抛异常，一种返回空值。具体的可以看Collection接口的整理，或者是API的描述，就不对每个方法做分析了。我觉得知道这些方法的作用与不同就行，具体的工作中使用哪个方法，可能还需要业务场景和业务逻辑来决定，使用的时候多仔细看下API就好。

下面来看看LinkedList的迭代器实现：

	//linkedList中获取迭代器方法
	public ListIterator<E> listIterator(int index) {
        checkPositionIndex(index);//边界检查
        return new ListItr(index);
    }
	//私有的ListIterator内部类
    private class ListItr implements ListIterator<E> {
        private Node<E> lastReturned = null;
        private Node<E> next;
        private int nextIndex;
        private int expectedModCount = modCount;//指定修改次数与list中的相等

        ListItr(int index) {//私有内部类的构造方法
            // assert isPositionIndex(index);
            next = (index == size) ? null : node(index);
            nextIndex = index;
        }

        public boolean hasNext() {
            return nextIndex < size;
        }

        public E next() {//都是以链表的形式来获取元素的，不像ArrayList都是用数组
            checkForComodification();
            if (!hasNext())
                throw new NoSuchElementException();

            lastReturned = next;
            next = next.next;
            nextIndex++;
            return lastReturned.item;
        }

        public boolean hasPrevious() {
            return nextIndex > 0;
        }
		//双端队列的listIterator需要实现的方法
        public E previous() {
            checkForComodification();
            if (!hasPrevious())
                throw new NoSuchElementException();

            lastReturned = next = (next == null) ? last : next.prev;
            nextIndex--;
            return lastReturned.item;
        }

        public int nextIndex() {
            return nextIndex;
        }

        public int previousIndex() {
            return nextIndex - 1;
        }
		//对list进行修改的set,add,remove方法
        public void remove() {
            checkForComodification();
            if (lastReturned == null)
                throw new IllegalStateException();

            Node<E> lastNext = lastReturned.next;
            unlink(lastReturned);
            if (next == lastReturned)
                next = lastNext;
            else
                nextIndex--;
            lastReturned = null;
            expectedModCount++;//修改后lsit都要对count次数的值进行修改
        }
		
        public void set(E e) {
            if (lastReturned == null)
                throw new IllegalStateException();
            checkForComodification();
            lastReturned.item = e;
        }

        public void add(E e) {
            checkForComodification();
            lastReturned = null;
            if (next == null)
                linkLast(e);
            else
                linkBefore(e, next);
            nextIndex++;
            expectedModCount++;//这里为啥不跟之前一样写 exp=modCount,虽然效果一样
        }

        final void checkForComodification() {
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
        }
    }


----------
下面是一个clone方法，注意是一个浅表复制：

    /**
     * Returns a shallow copy of this {@code LinkedList}. (The elements
     * themselves are not cloned.)
     *
     * @return a shallow copy of this {@code LinkedList} instance
     */
    public Object clone() {
        LinkedList<E> clone = superClone();

        // Put clone into "virgin" state
        clone.first = clone.last = null;
        clone.size = 0;
        clone.modCount = 0;

        // Initialize clone with our elements
        for (Node<E> x = first; x != null; x = x.next)
            clone.add(x.item);

        return clone;
    }


----------
到这里基本上比较重要的方法都整理完了。

----------
# 下面看看Vector类

public class Vector<E>
    extends AbstractList<E>
    implements List<E>, RandomAccess, Cloneable, java.io.Serializable{}
从JDK1.2开始实现了List接口，成为集合框架一员，但是Vector是同步的。同时它也是随机访问的，也是可增长的对象数组。

下面分析具体的代码。首先是变量的声明：
    
	protected Object[] elementData;//用于存储元素的数组

	 /**
     * The number of valid components in this {@code Vector} object.
     * Components {@code elementData[0]} through
     * {@code elementData[elementCount-1]} are the actual items.
     *
     * @serial
     */
	protected int elementCount;//实际存储的元素数量，而不是数组的容量

	 /**
     * The amount by which the capacity of the vector is automatically
     * incremented when its size becomes greater than its capacity.  If
     * the capacity increment is less than or equal to zero, the capacity
     * of the vector is doubled each time it needs to grow.
     *
     * @serial
     */
	protected int capacityIncrement;//自动增长的容量大小，如果为<=0则每次都翻倍

    /** use serialVersionUID from JDK 1.0.2 for interoperability */
    private static final long serialVersionUID = -2767605614048989439L;


----------
构造方法如下：

    public Vector(int initialCapacity, int capacityIncrement) {
        super();
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal Capacity: "+
                                               initialCapacity);
        this.elementData = new Object[initialCapacity];
        this.capacityIncrement = capacityIncrement;
    }

	/**
     * Constructs an empty vector with the specified initial capacity and
     * with its capacity increment equal to zero.
     *
     * @param   initialCapacity   the initial capacity of the vector
     * @throws IllegalArgumentException if the specified initial capacity
     *         is negative
     */
    public Vector(int initialCapacity) {//只指定初始容量，以后每次都翻倍增长
        this(initialCapacity, 0);
    }

    /**
     * Constructs an empty vector so that its internal data array
     * has size {@code 10} and its standard capacity increment is
     * zero.
     */
    public Vector() {//默认初始容量是10，以后都翻倍
        this(10);
    }

    /**
     * Constructs a vector containing the elements of the specified
     * collection, in the order they are returned by the collection's
     * iterator.
     *
     * @param c the collection whose elements are to be placed into this
     *       vector
     * @throws NullPointerException if the specified collection is null
     * @since   1.2
     */
    public Vector(Collection<? extends E> c) {//集合转为Vector的形式
        elementData = c.toArray();
        elementCount = elementData.length;
        // c.toArray might (incorrectly) not return Object[] (see 6260652)
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, elementCount, Object[].class);
    }


----------
其他的成员方法，值得注意的是，public方法几乎都是synchronized的方法（有的方法没有sync是因为它在内部调用了这些synchronized方法），说明了Vector在内部实现的同步。
    
	/**
     * Copies the components of this vector into the specified array.
     * The item at index {@code k} in this vector is copied into
     * component {@code k} of {@code anArray}.
     *
     * @param  anArray the array into which the components get copied
     * @throws NullPointerException if the given array is null
     * @throws IndexOutOfBoundsException if the specified array is not
     *         large enough to hold all the components of this vector
     * @throws ArrayStoreException if a component of this vector is not of
     *         a runtime type that can be stored in the specified array
     * @see #toArray(Object[])
     * 复制这个vector中的内容到指定的数组中，它会覆盖这个数组的前elementCount个元素。
     */
    public synchronized void copyInto(Object[] anArray) {
        System.arraycopy(elementData, 0, anArray, 0, elementCount);
    }

	/**
     * Trims the capacity of this vector to be the vector's current
     * size. If the capacity of this vector is larger than its current
     * size, then the capacity is changed to equal the size by replacing
     * its internal data array, kept in the field {@code elementData},
     * with a smaller one. An application can use this operation to
     * minimize the storage of a vector.
     * 将elementData数组长度变成当前数组中实际存储的元素个数
     */
    public synchronized void trimToSize() {
        modCount++;
        int oldCapacity = elementData.length;
        if (elementCount < oldCapacity) {
            elementData = Arrays.copyOf(elementData, elementCount);
        }
    }
	
	//确保这个vector的容量可以存储minCapacity个元素
	public synchronized void ensureCapacity(int minCapacity) {
        if (minCapacity > 0) {
            modCount++;
            ensureCapacityHelper(minCapacity);
        }
    }

    /**
     * This implements the unsynchronized semantics of ensureCapacity.
     * Synchronized methods in this class can internally call this
     * method for ensuring capacity without incurring the cost of an
     * extra synchronization.
     *
     * @see #ensureCapacity(int)
     * 当minCapacity比当前的elementData长度还长时才去增加容量
     */
    private void ensureCapacityHelper(int minCapacity) {
        // overflow-conscious code
        if (minCapacity - elementData.length > 0)
            grow(minCapacity);
    }

    /**
     * The maximum size of array to allocate.
     * Some VMs reserve some header words in an array.
     * Attempts to allocate larger arrays may result in
     * OutOfMemoryError: Requested array size exceeds VM limit
     */
    private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

	//增加这个vector中数组的容量
    private void grow(int minCapacity) {
        // overflow-conscious code
        int oldCapacity = elementData.length;
		//新容量=旧容量+capacityIncrement
        int newCapacity = oldCapacity + ((capacityIncrement > 0) ?
                                         capacityIncrement : oldCapacity);
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        elementData = Arrays.copyOf(elementData, newCapacity);
    }
	//当minCapacity比较大时，数组的最大长度就是最大的int值，这个做个溢出的处理吧。
    private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Integer.MAX_VALUE :
            MAX_ARRAY_SIZE;
    }

----------
    
	/**
     * Sets the size of this vector. If the new size is greater than the
     * current size, new {@code null} items are added to the end of
     * the vector. If the new size is less than the current size, all
     * components at index {@code newSize} and greater are discarded.
     *
     * @param  newSize   the new size of this vector
     * @throws ArrayIndexOutOfBoundsException if the new size is negative
     * 这个强制设置vector的大小，newSize<size用null填充，newSize>size就丢弃
     */
    public synchronized void setSize(int newSize) {
        modCount++;
        if (newSize > elementCount) {
            ensureCapacityHelper(newSize);
        } else {
            for (int i = newSize ; i < elementCount ; i++) {
                elementData[i] = null;
            }
        }
        elementCount = newSize;
    }

	/**
     * Returns the current capacity of this vector.
     *
     * @return  the current capacity (the length of its internal
     *          data array, kept in the field {@code elementData}
     *          of this vector)
     * 要注意它和size的区别，size是实际存储的元素个数，而这个只是当前数组最多可以存储的元素个数
     */
    public synchronized int capacity() {
        return elementData.length;
    }

    /**
     * Returns the number of components in this vector.
     *
     * @return  the number of components in this vector
     */
    public synchronized int size() {
        return elementCount;
    }

	/**
     * Tests if this vector has no components.
     *
     * @return  {@code true} if and only if this vector has
     *          no components, that is, its size is zero;
     *          {@code false} otherwise.
     */
    public synchronized boolean isEmpty() {
        return elementCount == 0;
    }


----------
	/**
     * Returns an enumeration of the components of this vector. The
     * returned {@code Enumeration} object will generate all items in
     * this vector. The first item generated is the item at index {@code 0},
     * then the item at index {@code 1}, and so on.
     *返回此向量的组件的枚举。返回的 Enumeration 对象将生成此向量中的所有项。
	 *生成的第一项为索引 0 处的项，然后是索引 1 处的项，依此类推。
     * @return  an enumeration of the components of this vector
     * @see     Iterator
     */
    public Enumeration<E> elements() {
        return new Enumeration<E>() {
            int count = 0;

            public boolean hasMoreElements() {
                return count < elementCount;
            }

            public E nextElement() {
                synchronized (Vector.this) {
                    if (count < elementCount) {
                        return elementData(count++);
                    }
                }
                throw new NoSuchElementException("Vector Enumeration");
            }
        };
    }

----------
Vector类是随机访问的实现了同步操作的类，因为线程同步，花了很多额外的开销。其他的方法基本上逻辑也就和ArrayList随机访问差不多。毕竟父类都是AbstractList嘛。这里就不多做额外的方法介绍了。


----------
## Stack ##
首先是类的声明：

public class Stack<E> extends Vector<E> {}

可以看出，该类继承Vector。查看官方的API文档：
Stack 类表示后进先出（LIFO）的对象堆栈。它通过五个操作对类 Vector 进行了扩展 ，允许将向量视为堆栈。它提供了通常的 push 和 pop 操作，以及取堆栈顶点的 peek 方法、测试堆栈是否为空的 empty 方法、在堆栈中查找项并确定到堆栈顶距离的 search 方法。

首次创建堆栈时，它不包含项。

Deque 接口及其实现提供了 LIFO 堆栈操作的更完整和更一致的 set，应该优先使用此 set，而非此类。例如：

   Deque<Integer> stack = new ArrayDeque<Integer>();

官方文档建议我们使用双边队列接口下的实现。这个是为啥呢？
我看网上有说:它其实并不是只能后进先出，因为继承自Vector，可以有很多操作，从某种意义上来讲，不是一个栈）；所以因此不推荐使用这个Stack，并且其继承了Vector，又是线程安全，开销比较高 ？

它新增了下面的几个方法：
    
	public E push(E item) {
        addElement(item);

        return item;
    }
	public synchronized E pop() {
        E       obj;
        int     len = size();

        obj = peek();
        removeElementAt(len - 1);

        return obj;
    }
	public synchronized E peek() {
        int     len = size();

        if (len == 0)
            throw new EmptyStackException();
        return elementAt(len - 1);
    }
	public boolean empty() {
        return size() == 0;//父类是synchronized的size方法
    }
	public synchronized int search(Object o) {
        int i = lastIndexOf(o);

        if (i >= 0) {
            return size() - i;
        }
        return -1;
    }

