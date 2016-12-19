# Arrays类 #
list用久了感觉数据结构，数组都被自己淡忘了。数据结构还是需要学习的，这个类是操作数组相关的类。查看官方的API文档说明：
> 此类包含用来操作数组（比如排序和搜索）的各种方法。此类还包含一个允许将数组作为列表来查看的静态工厂。

> 除非特别注明，否则如果指定数组引用为 null，则此类中的方法都会抛出 NullPointerException。

> 此类中所含方法的文档都包括对实现 的简短描述。应该将这些描述视为实现注意事项，而不应将它们视为规范 的一部分。实现者应该可以随意替代其他算法，只要遵循规范本身即可。（例如，sort(Object[]) 使用的算法不必是一个合并排序算法，但它必须是稳定的。）
> 此类是 Java Collections Framework 的成员。

public class Arrays{}


----------
查看构造方法，发现是私有化的。因此它对外提供的方法都是静态方法。
 // Suppresses default constructor, ensuring non-instantiability.
    private Arrays() {}

下面就是其他的方法：

	//一个排序方法
    public static void sort(int[] a) {
        DualPivotQuicksort.sort(a);
    }
	//对数组指定范围进行排序
	public static void sort(int[] a, int fromIndex, int toIndex) {
        rangeCheck(a.length, fromIndex, toIndex);
        DualPivotQuicksort.sort(a, fromIndex, toIndex - 1);
    }
	//还重载了其他的sort方法，只是数组类型不一样而已。底层都是使用的DualPivotQuicksort类中的排序方法。

DualPivotQuicksort是JDK1.7开始的采用的快速排序算法。

需要注意的是，DualPivotQuicksort这个排序算法是根据实际的经验得出的，以前的快速排序是分两部分排序。而DualPivotQuicksort是有两个指针，将要排序的数组分成了 3部分，然后进行排序。
可以参考下面这个链接：

[http://www.tuicool.com/articles/BfY7Nz](http://www.tuicool.com/articles/BfY7Nz "DualPivotQuicksort快速排序")


----------
	//给数组的每个元素都设置指定的值
    public static void fill(int[] a, int val) {
        for (int i = 0, len = a.length; i < len; i++)
            a[i] = val;
    }
	//同样，这个方法也重载了很多次，只是数组类型不一样。
	

----------
查找方法，使用二分查找：
    
	//在指定范围内进行二分查找
	public static int binarySearch(int[] a, int fromIndex, int toIndex,
                                   int key) {
        rangeCheck(a.length, fromIndex, toIndex);//边界查找
        return binarySearch0(a, fromIndex, toIndex, key);
    }

    // Like public version, but without range checks.
    private static int binarySearch0(int[] a, int fromIndex, int toIndex,
                                     int key) {
        int low = fromIndex;//定义low端位置
        int high = toIndex - 1;//定义high端位置

        while (low <= high) {
            int mid = (low + high) >>> 1;//计算mid--无符号右移，高位补0
            int midVal = a[mid];//mid的value

            if (midVal < key)
                low = mid + 1;//修改low端指针位置
            else if (midVal > key)
                high = mid - 1;//修改high端指针位置
            else
                return mid; // key found
        }
        return -(low + 1);  // key not found.返回的是
    }


----------
equals方法：

	//判断两个数组是否相等，这个相等要求的是两个数组中的每个元素都对应相等，就会返回true,否则返回false.
    public static boolean equals(int[] a, int[] a2) {
        if (a==a2)//引用相等就说明是同一个
            return true;
        if (a==null || a2==null)//只要有一个为null,就返回false.因为这个比较没有意义嘛
            return false;

        int length = a.length;
        if (a2.length != length)//长度比较，可以快速的判定不等
            return false;

        for (int i=0; i<length; i++)//每个位置都比较
            if (a[i] != a2[i])
                return false;

        return true;
    }

----------
copyOf方法：

	//复制一个original数组，指定长度为newLength。newLength小于original.length就丢弃，否则后面就填充空值。
    public static <T> T[] copyOf(T[] original, int newLength) {
        return (T[]) copyOf(original, newLength, original.getClass());
    }
	public static <T,U> T[] copyOf(U[] original, int newLength, Class<? extends T[]> newType) {
		//看是不是Object类
        T[] copy = ((Object)newType == (Object)Object[].class)
            ? (T[]) new Object[newLength]
            : (T[]) Array.newInstance(newType.getComponentType(), newLength);
        //复制original的元素到copy中
		System.arraycopy(original, 0, copy, 0,
                         Math.min(original.length, newLength));//min防止越界
        return copy;
    }

----------
copyOfRange方法：

     public static <T> T[] copyOfRange(T[] original, int from, int to) {
        return copyOfRange(original, from, to, (Class<T[]>) original.getClass());
    }

	//复制指定的范围的original的所有元素
	public static <T,U> T[] copyOfRange(U[] original, int from, int to, Class<? extends T[]> newType) {
        int newLength = to - from;
        if (newLength < 0)
            throw new IllegalArgumentException(from + " > " + to);
        T[] copy = ((Object)newType == (Object)Object[].class)
            ? (T[]) new Object[newLength]
            : (T[]) Array.newInstance(newType.getComponentType(), newLength);
        System.arraycopy(original, from, copy, 0,
                         Math.min(original.length - from, newLength));
        return copy;
    }


----------
让我感到疑惑的是，它还有个asList方法 
    
	public static <T> List<T> asList(T... a) {
        return new ArrayList<>(a);//私有类
    }
	 /**
     * @serial include
     */
    private static class ArrayList<E> extends AbstractList<E>
        implements RandomAccess, java.io.Serializable
    {
        private static final long serialVersionUID = -2764017481108945198L;
        private final E[] a;

        ArrayList(E[] array) {
            if (array==null)
                throw new NullPointerException();
            a = array;
        }

        public int size() {
            return a.length;
        }

        public Object[] toArray() {
            return a.clone();
        }

        public <T> T[] toArray(T[] a) {
            int size = size();
            if (a.length < size)
                return Arrays.copyOf(this.a, size,
                                     (Class<? extends T[]>) a.getClass());
            System.arraycopy(this.a, 0, a, 0, size);
            if (a.length > size)
                a[size] = null;
            return a;
        }

        public E get(int index) {
            return a[index];
        }

        public E set(int index, E element) {
            E oldValue = a[index];
            a[index] = element;
            return oldValue;
        }

        public int indexOf(Object o) {
            if (o==null) {
                for (int i=0; i<a.length; i++)
                    if (a[i]==null)
                        return i;
            } else {
                for (int i=0; i<a.length; i++)
                    if (o.equals(a[i]))
                        return i;
            }
            return -1;
        }

        public boolean contains(Object o) {
            return indexOf(o) != -1;
        }
    }



> 为啥不是用java.util.ArrayList这个list呢？要使用自己类的私有的内部类。这样的话，它不能使用它的add()方法，不具有正常的ArrayList的功能。