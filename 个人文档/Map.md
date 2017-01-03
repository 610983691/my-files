# Map #
类声明：
public interface Map<K,V>{}

之前我一直认为它继承了Collection接口，实际上它并没有，它只是属于集合框架。查看API的简短描述：
> 将键映射到值的对象。一个映射不能包含重复的键；每个键最多只能映射到一个值。

> 此接口取代 Dictionary 类，后者完全是一个抽象类，而不是一个接口。

> Map 接口提供三种collection 视图，允许以键集、值集或键-值映射关系集的形式查看某个映射的内容。映射顺序 定义为迭代器在映射的 collection 视图上返回其元素的顺序。某些映射实现可明确保证其顺序，如 TreeMap 类；另一些映射实现则不保证顺序，如 HashMap 类。

具体的还是看API，下面看下各个方法的定义：

     /**
     * Returns the number of key-value mappings in this map.  If the
     * map contains more than <tt>Integer.MAX_VALUE</tt> elements, returns
     * <tt>Integer.MAX_VALUE</tt>.
     *
     * @return the number of key-value mappings in this map
     */
    int size();
	/**
     * Associates the specified value with the specified key in this map
     * (optional operation).  If the map previously contained a mapping for
     * the key, the old value is replaced by the specified value.  (A map
     * <tt>m</tt> is said to contain a mapping for a key <tt>k</tt> if and only
     * if {@link #containsKey(Object) m.containsKey(k)} would return
     * <tt>true</tt>.)
     *
     * @param key key with which the specified value is to be associated
     * @param value value to be associated with the specified key
     * @return the previous value associated with <tt>key</tt>, or
     *         <tt>null</tt> if there was no mapping for <tt>key</tt>.
     *         (A <tt>null</tt> return can also indicate that the map
     *         previously associated <tt>null</tt> with <tt>key</tt>,
     *         if the implementation supports <tt>null</tt> values.)
     * @throws UnsupportedOperationException if the <tt>put</tt> operation
     *         is not supported by this map
     * @throws ClassCastException if the class of the specified key or value
     *         prevents it from being stored in this map
     * @throws NullPointerException if the specified key or value is null
     *         and this map does not permit null keys or values
     * @throws IllegalArgumentException if some property of the specified key
     *         or value prevents it from being stored in this map
     */
	V put(K key, V value);//放一个已经有的key时，之前的值会被覆盖

	void putAll(Map<? extends K, ? extends V> m);

----------

	/**
     * Returns a {@link Set} view of the keys contained in this map.
     * The set is backed by the map, so changes to the map are
     * reflected in the set, and vice-versa.  If the map is modified
     * while an iteration over the set is in progress (except through
     * the iterator's own <tt>remove</tt> operation), the results of
     * the iteration are undefined.  The set supports element removal,
     * which removes the corresponding mapping from the map, via the
     * <tt>Iterator.remove</tt>, <tt>Set.remove</tt>,
     * <tt>removeAll</tt>, <tt>retainAll</tt>, and <tt>clear</tt>
     * operations.  It does not support the <tt>add</tt> or <tt>addAll</tt>
     * operations.
     *
     * @return a set view of the keys contained in this map
     */
    Set<K> keySet();//返回键值的集合，它是Map的备份，对这个Set修改，或对Map修改会影响彼此。
	
	//返回这个Map的values的集合，因为value可以重复嘛，所以这里不能用Set返回。
	Collection<V> values();

	

----------
	/**
     * Returns a {@link Set} view of the mappings contained in this map.
     * The set is backed by the map, so changes to the map are
     * reflected in the set, and vice-versa.  If the map is modified
     * while an iteration over the set is in progress (except through
     * the iterator's own <tt>remove</tt> operation, or through the
     * <tt>setValue</tt> operation on a map entry returned by the
     * iterator) the results of the iteration are undefined.  The set
     * supports element removal, which removes the corresponding
     * mapping from the map, via the <tt>Iterator.remove</tt>,
     * <tt>Set.remove</tt>, <tt>removeAll</tt>, <tt>retainAll</tt> and
     * <tt>clear</tt> operations.  It does not support the
     * <tt>add</tt> or <tt>addAll</tt> operations.
     *
     * @return a set view of the mappings contained in this map
     */
    Set<Map.Entry<K, V>> entrySet();//这个Map中的键值映射视图

----------
内部接口:

	interface Entry<K,V> {
		K getKey();
		V getValue();
		V setValue(V value);

		boolean equals(Object o);

		
		int hashCode();
	}//


----------
## AbstractMap 抽象类 ##

public abstract class AbstractMap<K,V> implements Map<K,V>

API文档：
> 此类提供 Map 接口的骨干实现，以最大限度地减少实现此接口所需的工作。

> 要实现不可修改的映射，编程人员只需扩展此类并提供 entrySet 方法的实现即可，该方法将返回映射的映射关系 set 视图。通常，返回的 set 将依次在 AbstractSet 上实现。此 set 不支持 add 或 remove 方法，其迭代器也不支持 remove 方法。

> 要实现可修改的映射，编程人员必须另外重写此类的 put 方法（否则将抛出 UnsupportedOperationException），entrySet().iterator() 返回的迭代器也必须另外实现其 remove 方法。


具体方法如下：
    public int size() {
        return entrySet().size();//可以看出是通过entrySet方法来实现Map的。
    }
    
	public boolean containsValue(Object value) {
        Iterator<Entry<K,V>> i = entrySet().iterator();
        if (value==null) {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (e.getValue()==null)
                    return true;
            }
        } else {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (value.equals(e.getValue()))
                    return true;
            }
        }
        return false;
    }
	
	/**
     * {@inheritDoc}
     *
     * <p>This implementation iterates over <tt>entrySet()</tt> searching
     * for an entry with the specified key.  If such an entry is found,
     * the entry's value is returned.  If the iteration terminates without
     * finding such an entry, <tt>null</tt> is returned.  Note that this
     * implementation requires linear time in the size of the map; many
     * implementations will override this method.
     *
     * @throws ClassCastException            {@inheritDoc}
     * @throws NullPointerException          {@inheritDoc}
     */
    public V get(Object key) {
        Iterator<Entry<K,V>> i = entrySet().iterator();
        if (key==null) {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (e.getKey()==null) //可以接受null的key
                    return e.getValue();
            }
        } else {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (key.equals(e.getKey()))
                    return e.getValue();
            }
        }
        return null;
    }

----------
这段代码我怎么感觉可以不这样写呢？

    /**
     * {@inheritDoc}
     *
     * <p>This implementation iterates over <tt>entrySet()</tt> searching for an
     * entry with the specified key.  If such an entry is found, its value is
     * obtained with its <tt>getValue</tt> operation, the entry is removed
     * from the collection (and the backing map) with the iterator's
     * <tt>remove</tt> operation, and the saved value is returned.  If the
     * iteration terminates without finding such an entry, <tt>null</tt> is
     * returned.  Note that this implementation requires linear time in the
     * size of the map; many implementations will override this method.
     *
     * <p>Note that this implementation throws an
     * <tt>UnsupportedOperationException</tt> if the <tt>entrySet</tt>
     * iterator does not support the <tt>remove</tt> method and this map
     * contains a mapping for the specified key.
     *
     * @throws UnsupportedOperationException {@inheritDoc}
     * @throws ClassCastException            {@inheritDoc}
     * @throws NullPointerException          {@inheritDoc}
     */
    public V remove(Object key) {
        Iterator<Entry<K,V>> i = entrySet().iterator();
        Entry<K,V> correctEntry = null;
        if (key==null) {
            while (correctEntry==null && i.hasNext()) {
                Entry<K,V> e = i.next();
                if (e.getKey()==null)
                    correctEntry = e;
            }
        } else {
            while (correctEntry==null && i.hasNext()) {
                Entry<K,V> e = i.next();
                if (key.equals(e.getKey()))
                    correctEntry = e;
            }
        }

        V oldValue = null;
        if (correctEntry !=null) {
            oldValue = correctEntry.getValue();
            i.remove();
        }
        return oldValue;
    }

	是不是可以考虑这样写？---写了之后才发现，确实之前的写法更清晰。看起来有优化空间，但是实际上考虑到null值等限制条件，并没有太多优化。
	public V remove(Object key) {
        Iterator<Entry<K,V>> i = entrySet().iterator();
       Entry<K,V> correctEntry = null;
        if (key==null) {
            while (correctEntry==null && i.hasNext()) {
                Entry<K,V> e = i.next();
                if (e.getKey()==null){

                   correctEntry= i.remove();
					return correctEntry.getvalue()；
				}	
            }
        } else {
            while (correctEntry==null && i.hasNext()) {
                Entry<K,V> e = i.next();
                if (key.equals(e.getKey()))
                    correctEntry = e;
            }
        }

        V oldValue = null;
        if (correctEntry !=null) {
            oldValue = correctEntry.getValue();
            i.remove();
        }
        return oldValue;
    }

----------
下面还有定义的变量字段：

	transient volatile Set<K>        keySet = null;
    transient volatile Collection<V> values = null;

	需要注意的是，这两个字段不能序列化，同时是tolatile修饰的。查看下volatile关键字说明：
	它是用来保证：某线程对工作内存中volatile变量的写操作会立即更新到主存中，并且会让其他的线程工作内存中的缓存失效。--保证修改对其他线程可见，但是它不能保证同步。具体还是看给的链接文章。
	
	我觉得这两篇文章写的还比较好：

[https://segmentfault.com/a/1190000006924914](https://segmentfault.com/a/1190000006924914 "Volatile关键字，从内存模型分析")

[http://www.cnblogs.com/aigongsi/archive/2012/04/01/2429166.html](http://www.cnblogs.com/aigongsi/archive/2012/04/01/2429166.html "Volatile关键字解释")

----------
对应的获取keySet和Values集合方法：
    
	public Set<K> keySet() {
        if (keySet == null) {
            keySet = new AbstractSet<K>() {//返回的是抽象集合对象
                public Iterator<K> iterator() {
                    return new Iterator<K>() {//迭代器应该返回key的迭代。
                        private Iterator<Entry<K,V>> i = entrySet().iterator();

                        public boolean hasNext() {
                            return i.hasNext();
                        }

                        public K next() {
                            return i.next().getKey();
                        }

                        public void remove() {
                            i.remove();
                        }
                    };
                }

                public int size() {
					//必须是AbstarctMap.this,不然this会指向AbstractSet
                    return AbstractMap.this.size();
                }

                public boolean isEmpty() {
                    return AbstractMap.this.isEmpty();
                }

                public void clear() {
                    AbstractMap.this.clear();
                }

                public boolean contains(Object k) {
                    return AbstractMap.this.containsKey(k);
                }
            };
        }
        return keySet;
    }

	public Collection<V> values() {
        if (values == null) {
            values = new AbstractCollection<V>() {
                public Iterator<V> iterator() {
                    return new Iterator<V>() {
                        private Iterator<Entry<K,V>> i = entrySet().iterator();

                        public boolean hasNext() {
                            return i.hasNext();//都是一个entry
                        }

                        public V next() {
                            return i.next().getValue();//迭代器返回的值不一样
                        }

                        public void remove() {
                            i.remove();
                        }
                    };
                }

                public int size() {
                    return AbstractMap.this.size();
                }

                public boolean isEmpty() {
                    return AbstractMap.this.isEmpty();
                }

                public void clear() {
                    AbstractMap.this.clear();
                }

                public boolean contains(Object v) {
                    return AbstractMap.this.containsValue(v);
                }
            };
        }
        return values;
    }


----------
下面是Entry接口的实现：

    /**
     * An Entry maintaining a key and a value.  The value may be
     * changed using the <tt>setValue</tt> method.  This class
     * facilitates the process of building custom map
     * implementations. For example, it may be convenient to return
     * arrays of <tt>SimpleEntry</tt> instances in method
     * <tt>Map.entrySet().toArray</tt>.
     *
     * @since 1.6
     */
    public static class SimpleEntry<K,V>
        implements Entry<K,V>, java.io.Serializable{}

	主要的变量和方法如下：
	private static final long serialVersionUID = -8499721149061103585L;

    private final K key;//key是不可修改的，所以用final修饰
    private V value;//value可修改
	
	构造方法：
	public SimpleEntry(K key, V value) {
            this.key   = key;
            this.value = value;
        }
	
	public SimpleEntry(Entry<? extends K, ? extends V> entry) {
            this.key   = entry.getKey();
            this.value = entry.getValue();
        }

	public V setValue(V value) {//设置一个当前的entry的值
            V oldValue = this.value;
            this.value = value;
            return oldValue;
        }
	重写的equals方法
	public boolean equals(Object o) {
            if (!(o instanceof Map.Entry))
                return false;
            Map.Entry e = (Map.Entry)o;
            return eq(key, e.getKey()) && eq(value, e.getValue());
        }
	/**
		这个方法不在这个内部类里边，在AbstractMap里边
     * Utility method for SimpleEntry and SimpleImmutableEntry.
     * Test for equality, checking for nulls.
     */
    private static boolean eq(Object o1, Object o2) {
        return o1 == null ? o2 == null : o1.equals(o2);
    }

----------
内部类：
	public static class SimpleImmutableEntry<K,V>
        implements Entry<K,V>, java.io.Serializable
	
	 private final K key;
        private final V value;
	它与前面的那个内部类的不同之处在于，它的value值也是不可修改的。
	因此，它还不支持setValue方法，该方法会抛出异常。如下
	
	public V setValue(V value) {
        throw new UnsupportedOperationException();
    }

----------
## HashMap 类 ##
类的声明：

public class HashMap<K,V> extends AbstractMap<K,V>  implements Map<K,V>, Cloneable, Serializable{}
> 它是基于哈希表的 Map 接口的实现。此实现提供所有可选的映射操作，并允许使用 null 值和 null 键。（除了非同步和允许使用 null 之外，HashMap 类与 Hashtable 大致相同。）此类不保证映射的顺序，特别是它不保证该顺序恒久不变。
> 
> 注意，此实现不是同步的。
还是直接看API文档描述吧，太多了，这里不粘贴了。

> 需要注意的就是对初始容量和加载因子的值进行合理设置，以便尽量减少rehash操作。

----------
来看看类的成员变量声明：

    /**
     * The default initial capacity - MUST be a power of two.
     */
    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16

    /**
     * The maximum capacity, used if a higher value is implicitly specified
     * by either of the constructors with arguments.
     * MUST be a power of two <= 1<<30.
     */
    static final int MAXIMUM_CAPACITY = 1 << 30;

    /**
     * The load factor used when none specified in constructor.
     */
    static final float DEFAULT_LOAD_FACTOR = 0.75f;

	容量要求是2的n次方，默认值的初始化时为了看起来更直观。

----------
类的map键-值映射数组：

	/**
     * An empty table instance to share when the table is not inflated.
     */
    static final Entry<?,?>[] EMPTY_TABLE = {};

    /**
     * The table, resized as necessary. Length MUST Always be a power of two.
     */
    transient Entry<K,V>[] table = (Entry<K,V>[]) EMPTY_TABLE;

----------
    transient int size;

	/**
     * The next size value at which to resize (capacity * load factor).
     * @serial
     */
	int threshold;//

	final float loadFactor;

	transient int modCount;

	static final int ALTERNATIVE_HASHING_THRESHOLD_DEFAULT = Integer.MAX_VALUE;


----------
构造方法：

    public HashMap(int initialCapacity, float loadFactor) {
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal initial capacity: " +
                                               initialCapacity);
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        if (loadFactor <= 0 || Float.isNaN(loadFactor))
            throw new IllegalArgumentException("Illegal load factor: " +
                                               loadFactor);

        this.loadFactor = loadFactor;
        threshold = initialCapacity;//下一次resize的值，因为现在还没初始化，所以下一次resize的值就是初始容量。
        init();
    }

	/**
     * Initialization hook for subclasses. This method is called
     * in all constructors and pseudo-constructors (clone, readObject)
     * after HashMap has been initialized but before any entries have
     * been inserted.  (In the absence of this method, readObject would
     * require explicit knowledge of subclasses.)
     */
    void init() {子类初始化的钩子？在映射插入之前被调用。
    }

	/**
     * Inflates the table.
     */
    private void inflateTable(int toSize) {//map扩容
        // Find a power of 2 >= toSize
        int capacity = roundUpToPowerOf2(toSize);

        threshold = (int) Math.min(capacity * loadFactor, MAXIMUM_CAPACITY + 1);
        table = new Entry[capacity];
        initHashSeedAsNeeded(capacity);
    }

----------
    /**
     * Returns the entry associated with the specified key in the
     * HashMap.  Returns null if the HashMap contains no mapping
     * for the key.
     */
    final Entry<K,V> getEntry(Object key) {//它的查找方式
        if (size == 0) {
            return null;
        }

        int hash = (key == null) ? 0 : hash(key);//计算hash值
        for (Entry<K,V> e = table[indexFor(hash, table.length)];
             e != null;
             e = e.next) {
            Object k;
            if (e.hash == hash &&
                ((k = e.key) == key || (key != null && key.equals(k))))
                return e;
        }
        return null;
    }

	/**
     * Returns index for hash code h.
     */
    static int indexFor(int h, int length) {
        // assert Integer.bitCount(length) == 1 : "length must be a non-zero power of 2";
        return h & (length-1);
    }

	final int hash(Object k) {
        int h = hashSeed;
        if (0 != h && k instanceof String) {
            return sun.misc.Hashing.stringHash32((String) k);//String的hash值计算
        }

        h ^= k.hashCode();

        // This function ensures that hashCodes that differ only by
        // constant multiples at each bit position have a bounded
        // number of collisions (approximately 8 at default load factor).
        h ^= (h >>> 20) ^ (h >>> 12);
        return h ^ (h >>> 7) ^ (h >>> 4);
    }

必须要搞懂hash才行


----------
下面是Entry内部类：
    
	static class Entry<K,V> implements Map.Entry<K,V> {
        final K key;
        V value;
        Entry<K,V> next;
        int hash;

        /**
         * Creates new entry.
         */
        Entry(int h, K k, V v, Entry<K,V> n) {
            value = v;
            next = n;
            key = k;
            hash = h;
        }

        public final K getKey() {
            return key;
        }

        public final V getValue() {
            return value;
        }

        public final V setValue(V newValue) {
            V oldValue = value;
            value = newValue;
            return oldValue;
        }

        public final boolean equals(Object o) {
            if (!(o instanceof Map.Entry))
                return false;
            Map.Entry e = (Map.Entry)o;
            Object k1 = getKey();
            Object k2 = e.getKey();
            if (k1 == k2 || (k1 != null && k1.equals(k2))) {
                Object v1 = getValue();
                Object v2 = e.getValue();
                if (v1 == v2 || (v1 != null && v1.equals(v2)))
                    return true;
            }
            return false;
        }

        public final int hashCode() {
            return Objects.hashCode(getKey()) ^ Objects.hashCode(getValue());
        }

        public final String toString() {
            return getKey() + "=" + getValue();
        }

        /**
         * This method is invoked whenever the value in an entry is
         * overwritten by an invocation of put(k,v) for a key k that's already
         * in the HashMap.
         */
        void recordAccess(HashMap<K,V> m) {
        }

        /**
         * This method is invoked whenever the entry is
         * removed from the table.
         */
        void recordRemoval(HashMap<K,V> m) {
        }
    }


----------
再看下最常用的put方法：

	public V put(K key, V value) {
        if (table == EMPTY_TABLE) {//空表的话要新建一个
            inflateTable(threshold);//扩容
        }
        if (key == null)
            return putForNullKey(value);//放一个null的key使用这个方法
        int hash = hash(key);
        int i = indexFor(hash, table.length);
        for (Entry<K,V> e = table[i]; e != null; e = e.next) {//如果key已经用过了
            Object k;
            if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
                V oldValue = e.value;
                e.value = value;
                e.recordAccess(this);
                return oldValue;
            }
        }

        modCount++;
        addEntry(hash, key, value, i);//key没有使用过就新增一个entry实例
        return null;
    }

	void addEntry(int hash, K key, V value, int bucketIndex) {
        if ((size >= threshold) && (null != table[bucketIndex])) {
            resize(2 * table.length);
            hash = (null != key) ? hash(key) : 0;//null的hash码是0
            bucketIndex = indexFor(hash, table.length);//indexfor方法
        }

        createEntry(hash, key, value, bucketIndex);
    }

	void createEntry(int hash, K key, V value, int bucketIndex) {
        Entry<K,V> e = table[bucketIndex];
        table[bucketIndex] = new Entry<>(hash, key, value, e);//新实例的下一个是e.怎么感觉像链表一样呢 --就是链表
		//这个根据hash算出来，有可能两个key要放在table的同一个位置，因此这个数组里面的entry会有next.
		//自己实际debug测试，size=20，但是table里面数组元素个数只有15个。就是因为有的位置上存了"多个"元素。

        size++;
    }
	
	//因为length是2的n次方，所以length-1 = X111110
	static int indexFor(int h, int length) {
        // assert Integer.bitCount(length) == 1 : "length must be a non-zero power of 2";
        return h & (length-1);
    }

	final Entry<K, V> getEntry(Object key) {
		if (size == 0) {
			return null;
		}

		int hash = (key == null) ? 0 : hash(key);//算出hash值
		for (Entry<K, V> e = table[indexFor(hash,
				table.length)]; e != null; e = e.next) {//根据上面的分析，因为这个位置可能有多个元素，所以要循环
			Object k;
			if (e.hash == hash
					&& ((k = e.key) == key || (key != null && key.equals(k))))
				return e;
		}
		return null;
	}

	public V remove(Object key) {
		Entry<K, V> e = removeEntryForKey(key);
		return (e == null ? null : e.value);
	}

	final Entry<K, V> removeEntryForKey(Object key) {
		if (size == 0) {
			return null;
		}
		int hash = (key == null) ? 0 : hash(key);
		int i = indexFor(hash, table.length);
		Entry<K, V> prev = table[i];//根据hash值算出在table中的位置并获取到它
		Entry<K, V> e = prev;

		while (e != null) {
			Entry<K, V> next = e.next;
			Object k;
			if (e.hash == hash
					&& ((k = e.key) == key || (key != null && key.equals(k)))) {
				modCount++;
				size--;
				if (prev == e)//找到之后把链表中的这个节点要删掉。
					table[i] = next;
				else
					prev.next = next;
				e.recordRemoval(this);
				return e;
			}
			prev = e;//往后面找，找到就删
			e = next;
		}

		return e;
	}


----------
    //由于散列存储的关系，不能由table[i]来直接获取元素的值哦
	public boolean containsValue(Object value) {
		if (value == null)
			return containsNullValue();

		Entry[] tab = table;
		for (int i = 0; i < tab.length; i++)
			for (Entry e = tab[i]; e != null; e = e.next)
				if (value.equals(e.value))
					return true;
		return false;
	}


----------
迭代器实现：
定义了抽象的hash迭代器并提供了骨干的实现
    private abstract class HashIterator<E> implements Iterator<E> {
		Entry<K, V> next; // next entry to return
		int expectedModCount; // For fast-fail
		int index; // current slot
		Entry<K, V> current; // current entry

		HashIterator() {
			expectedModCount = modCount;
			if (size > 0) { // advance to first entry //index是怎么初始化的呢，虽然int变量的默认值是0，但是这样写未免有点？
				Entry[] t = table;
				while (index < t.length && (next = t[index++]) == null);
			}
		}

		public final boolean hasNext() {//对于entry来说，是table中的一个非空元素
			return next != null;
		}

		final Entry<K, V> nextEntry() {
			if (modCount != expectedModCount)
				throw new ConcurrentModificationException();
			Entry<K, V> e = next;
			if (e == null)
				throw new NoSuchElementException();

			if ((next = e.next) == null) {//设置nextEntry
				Entry[] t = table;
				while (index < t.length && (next = t[index++]) == null);
			}
			current = e;
			return e;
		}

		public void remove() {
			if (current == null)
				throw new IllegalStateException();
			if (modCount != expectedModCount)
				throw new ConcurrentModificationException();
			Object k = current.key;
			current = null;
			HashMap.this.removeEntryForKey(k);
			expectedModCount = modCount;
		}
	}

	/***
	*下面分别是key,value和entry的迭代器实例，他们继承上面的hashIterator并各自实现next方法。
	*/
	private final class ValueIterator extends HashIterator<V> {
		public V next() {
			return nextEntry().value;
		}
	}

	private final class KeyIterator extends HashIterator<K> {
		public K next() {
			return nextEntry().getKey();
		}
	}

	private final class EntryIterator extends HashIterator<Map.Entry<K, V>> {
		public Map.Entry<K, V> next() {
			return nextEntry();
		}
	}

----------
> KeySet对应的集合，它是HashMap内部的私有AbstractSet实现的。
> 
	private final class KeySet extends AbstractSet<K> {
		public Iterator<K> iterator() {
			return newKeyIterator();//前面的key迭代器
		}
		public int size() {
			return size;
		}
		public boolean contains(Object o) {
			return containsKey(o);
		}
		public boolean remove(Object o) {
			return HashMap.this.removeEntryForKey(o) != null;
		}
		public void clear() {
			HashMap.this.clear();//这个Hash.this，就可以保证，外部调用keySet的clear就会清除掉这个map实例的table中的内容.
		}
	}

	//这个方法和上面的keySet一样
	public Collection<V> values() {
		Collection<V> vs = values;
		return (vs != null ? vs : (values = new Values()));
	}

	private final class Values extends AbstractCollection<V> {
		public Iterator<V> iterator() {
			return newValueIterator();
		}
		public int size() {
			return size;
		}
		public boolean contains(Object o) {
			return containsValue(o);
		}
		public void clear() {
			HashMap.this.clear();
		}
	}

自己说了这么多，主要是看代码去了，对代码的实现和HashMap实现原理有了一定理解。同时，自己的文档整理起来还是不好阅读，因为代码太多了。不过，想要快速浏览，可以参考这个文章：
[http://blog.csdn.net/caihaijiang/article/details/6280251](http://blog.csdn.net/caihaijiang/article/details/6280251 "HashMap详解")


----------
# TreeMap 类 #

类的声明：
public class TreeMap<K,V>
    extends AbstractMap<K,V>
    implements NavigableMap<K,V>, Cloneable, java.io.Serializable

API文档描述：
基于红黑树（Red-Black tree）的 NavigableMap 实现。该映射根据其键的自然顺序进行排序，或者根据创建映射时提供的 Comparator 进行排序，具体取决于使用的构造方法。

此实现为 containsKey、get、put 和 remove 操作提供受保证的 log(n) 时间开销。这些算法是 Cormen、Leiserson 和 Rivest 的 Introduction to Algorithms 中的算法的改编。

注意，如果要正确实现 Map 接口，则有序映射所保持的顺序（无论是否明确提供了比较器）都必须与 equals 一致。（关于与 equals 一致 的精确定义，请参阅 Comparable 或 Comparator）。这是因为 Map 接口是按照 equals 操作定义的，但有序映射使用它的 compareTo（或 compare）方法对所有键进行比较，因此从有序映射的观点来看，此方法认为相等的两个键就是相等的。即使排序与 equals 不一致，有序映射的行为仍然是 定义良好的，只不过没有遵守 Map 接口的常规协定。

注意，此实现不是同步的。
它不接受null的key值。

红黑树的简单介绍：
[http://www.cnblogs.com/skywang12345/p/3245399.html](http://www.cnblogs.com/skywang12345/p/3245399.html "红黑树介绍")

对本文TreeMap的代码分析与介绍：
[http://blog.csdn.net/bigtree_3721/article/details/42050697](http://blog.csdn.net/bigtree_3721/article/details/42050697 "TreeMap源码分析与介绍")

下面看看代码中能描述上面说的这些特性的代码实现：


----------
   	//变量定义
	private final Comparator<? super K> comparator;//比较器

    private transient Entry<K,V> root = null;

    /**
     * The number of entries in the tree
     */
    private transient int size = 0;

    /**
     * The number of structural modifications to the tree.
     */
    private transient int modCount = 0;

可以看出TreeMap并没有像之前的HashMap那样使用一个数组来存储键值映射关系。而是使用一个root来表示，这很正常，因为这个是基于树来实现的。而HashMap是散列的存储，就要用到数组。
而它的内部类也没有多特殊的方法，只是为了实现红黑树会有多个属性。

	Entry内部类：
	static final class Entry<K,V> implements Map.Entry<K,V> {
        K key;
        V value;
        Entry<K,V> left = null;
        Entry<K,V> right = null;
        Entry<K,V> parent;
        boolean color = BLACK; //每个节点所拥有的属性

        /**
         * Make a new cell with given key, value, and parent, and with
         * {@code null} child links, and BLACK color.
         */
        Entry(K key, V value, Entry<K,V> parent) {
            this.key = key;
            this.value = value;
            this.parent = parent;
        }

        public K getKey() {
            return key;
        }
     
        public V getValue() {
            return value;
        }

        public V setValue(V value) {
            V oldValue = this.value;
            this.value = value;
            return oldValue;
        }

        public boolean equals(Object o) {
            if (!(o instanceof Map.Entry))
                return false;
            Map.Entry<?,?> e = (Map.Entry<?,?>)o;

            return valEquals(key,e.getKey()) && valEquals(value,e.getValue());
        }

        public int hashCode() {
            int keyHash = (key==null ? 0 : key.hashCode());
            int valueHash = (value==null ? 0 : value.hashCode());
            return keyHash ^ valueHash;
        }

        public String toString() {
            return key + "=" + value;
        }
    }

----------
因为是使用了红黑树---特殊的二叉查找树，因此这个树是二叉排序的。所以会有下面的方法：

	//分别获取树的最小和最大的entry

	 final Entry<K,V> getFirstEntry() {
        Entry<K,V> p = root;
        if (p != null)
            while (p.left != null)
                p = p.left;
        return p;
    }

    /**
     * Returns the last Entry in the TreeMap (according to the TreeMap's
     * key-sort function).  Returns null if the TreeMap is empty.
     */
    final Entry<K,V> getLastEntry() {
        Entry<K,V> p = root;
        if (p != null)
            while (p.right != null)
                p = p.right;
        return p;
    }

二叉树的查找下一个方法：

	 /**
     * Returns the successor of the specified Entry, or null if no such.
     * 这个方法是获取当前entry的比它大下一个entry节点
     * 画图画图看
     */
    static <K,V> TreeMap.Entry<K,V> successor(Entry<K,V> t) {
        if (t == null)
            return null;
        else if (t.right != null) {//右节点中序号最小的
            Entry<K,V> p = t.right;
            while (p.left != null)
                p = p.left;
            return p;
        } else {
            Entry<K,V> p = t.parent;
            Entry<K,V> ch = t;
            while (p != null && ch == p.right) {//父节点中最小的节点，如果它一直都是右节点就往前不断的遍历
                ch = p;
                p = p.parent;
            }
            return p;
        }
    }

	/**
     * Returns the predecessor of the specified Entry, or null if no such.
     * 获取它的前一个节点，根据二叉排序树来说，就是她的左子节点的最右边节点或者是它的父节点（当它是该父节点的右子节点时）
     */
    static <K,V> Entry<K,V> predecessor(Entry<K,V> t) {
        if (t == null)
            return null;
        else if (t.left != null) {
            Entry<K,V> p = t.left;
            while (p.right != null)
                p = p.right;
            return p;
        } else {
            Entry<K,V> p = t.parent;
            Entry<K,V> ch = t;
            while (p != null && ch == p.left) {//简洁有效
                ch = p;
                p = p.parent;
            }
            return p;
        }
    }


----------

红黑树的操作：

    /** From CLR */
    private void rotateLeft(Entry<K,V> p) {左旋
        if (p != null) {
            Entry<K,V> r = p.right;
            p.right = r.left;
            if (r.left != null)
                r.left.parent = p;
            r.parent = p.parent;
            if (p.parent == null)
                root = r;
            else if (p.parent.left == p)
                p.parent.left = r;
            else
                p.parent.right = r;
            r.left = p;
            p.parent = r;
        }
    }

    /** From CLR */
    private void rotateRight(Entry<K,V> p) {//右旋
        if (p != null) {
            Entry<K,V> l = p.left;
            p.left = l.right;
            if (l.right != null) l.right.parent = p;
            l.parent = p.parent;
            if (p.parent == null)
                root = l;
            else if (p.parent.right == p)
                p.parent.right = l;
            else p.parent.left = l;
            l.right = p;
            p.parent = l;
        }
    }


----------
put方法：
    
	public V put(K key, V value) {
        Entry<K,V> t = root;
        if (t == null) {//如果为null就新建一个entry
            compare(key, key); // type (and possibly null) check
			//这里是用比较器，可以外部传一个comparator进来，否则为null。这样的话，就会使用key所带的比较器来比较。意思就是key类型，必须要实现compareTo方法
            root = new Entry<>(key, value, null);
            size = 1;
            modCount++;
            return null;
        }
        int cmp;
        Entry<K,V> parent;
        // split comparator and comparable paths
        Comparator<? super K> cpr = comparator;
        if (cpr != null) {
            do {
                parent = t;
                cmp = cpr.compare(key, t.key);
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while (t != null);
        }
        else {
            if (key == null)
                throw new NullPointerException();
            Comparable<? super K> k = (Comparable<? super K>) key;//强转为comparable类型---这就说明，Key必须要实现compareble接口
            do {
                parent = t;
                cmp = k.compareTo(t.key);
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while (t != null);
        }
        Entry<K,V> e = new Entry<>(key, value, parent);
        if (cmp < 0)
            parent.left = e;
        else
            parent.right = e;
        fixAfterInsertion(e);
        size++;
        modCount++;
        return null;
    }

针对上面的TreeMap，我在本地环境运行如下代码：
    
	public class TestTreeMap {

		public static void main(String[] args) {
			// TODO Auto-generated method stub
			TreeMap<TestTreeMap, String> map = new TreeMap<TestTreeMap, String>();
			TestTreeMap t1 = new TestTreeMap();
			TestTreeMap t2 = new TestTreeMap();
			map.put(t1, "12");//报错---报错原因就是上面方法中的compare方法，
			map.put(t2, "123");
		}

	}
由于TestTreeMap没有实现Compareble接口，因此不能将TestTreeMap作为Key。很重要，以后使用TreeMap的时候需要注意，不要很容易就给自己的程序产生bug而且难以理解。不过还好，遇到这个问题的人应该不在少数。


----------
get方法：

	public V get(Object key) {
        Entry<K,V> p = getEntry(key);
        return (p==null ? null : p.value);
    }

	final Entry<K,V> getEntry(Object key) {
        // Offload comparator-based version for sake of performance
        if (comparator != null)
            return getEntryUsingComparator(key);
        if (key == null)
            throw new NullPointerException();//不支持null值
        Comparable<? super K> k = (Comparable<? super K>) key;
        Entry<K,V> p = root;
        while (p != null) {
            int cmp = k.compareTo(p.key);
            if (cmp < 0)
                p = p.left;
            else if (cmp > 0)
                p = p.right;
            else
                return p;
        }
        return null;
    }

----------
# SortedMap 接口#
	
更具体的还是看接口文档描述：

进一步提供关于键的总体排序 的 Map。该映射是根据其键的自然顺序进行排序的，或者根据通常在创建有序映射时提供的 Comparator 进行排序。对有序映射的 collection 视图（由 entrySet、keySet 和 values 方法返回）进行迭代时，此顺序就会反映出来。要采用此排序方式，还需要提供一些其他操作（此接口是 SortedSet 的对应映射）。

插入有序映射的所有键都必须实现 Comparable 接口（或者被指定的比较器接受）。另外，所有这些键都必须是可互相比较的：对有序映射中的任意两个键 k1 和 k2 执行 k1.compareTo(k2)（或 comparator.compare(k1, k2)）都不得抛出 ClassCastException。试图违反此限制将导致违反规则的方法或者构造方法调用抛出 ClassCastException。



----------
# HashTable类 #
类的声明如下;

public class Hashtable<K,V>
    extends Dictionary<K,V>
    implements Map<K,V>, Cloneable, java.io.Serializable {

API文档中的部分描述如下：
> 此类实现一个哈希表，该哈希表将键映射到相应的值。任何非 null 对象都可以用作键或值。



> 为了成功地在哈希表中存储和获取对象，用作键的对象必须实现 hashCode 方法和 equals 方法。



> Hashtable 的实例有两个参数影响其性能：初始容量 和加载因子。容量 是哈希表中桶 的数量，初始容量 就是哈希表创建时的容量。注意，哈希表的状态为 open：在发生“哈希冲突”的情况下，单个桶会存储多个条目，这些条目必须按顺序搜索。加载因子 是对哈希表在其容量自动增加之前可以达到多满的一个尺度。初始容量和加载因子这两个参数只是对该实现的提示。关于何时以及是否调用 rehash 方法的具体细节则依赖于该实现。

> 从Java 2 平台 v1.2起，此类就被改进以实现 Map 接口，使它成为 Java Collections Framework 中的一个成员。不像新的 collection 实现，**Hashtable 是同步的**


----------
字段定义：

	private transient Entry<K,V>[] table;

	private transient int count;

	private int threshold;

	private float loadFactor;

	private transient int modCount = 0;


----------
看看hashtable的内部类Entry:

    private static class Entry<K,V> implements Map.Entry<K,V> {
        int hash;
        final K key;
        V value;
        Entry<K,V> next;//--字段都和hashMap一样

        protected Entry(int hash, K key, V value, Entry<K,V> next) {
            this.hash = hash;
            this.key =  key;
            this.value = value;
            this.next = next;
        }

        protected Object clone() {//clone方法，递归的clone.所以是一个深拷贝
            return new Entry<>(hash, key, value,
                                  (next==null ? null : (Entry<K,V>) next.clone()));
        }

        // Map.Entry Ops

        public K getKey() {
            return key;
        }

        public V getValue() {
            return value;
        }

        public V setValue(V value) {
            if (value == null)//不接受null值，hashMap可以！！注意是值都不能为null.
                throw new NullPointerException();

            V oldValue = this.value;
            this.value = value;
            return oldValue;
        }

        public boolean equals(Object o) {
            if (!(o instanceof Map.Entry))
                return false;
            Map.Entry<?,?> e = (Map.Entry)o;

            return key.equals(e.getKey()) && value.equals(e.getValue());
        }

        public int hashCode() {
            return (Objects.hashCode(key) ^ Objects.hashCode(value));
        }

        public String toString() {
            return key.toString()+"="+value.toString();
        }
    }


----------
实现同步以及常用的public 方法：

    public synchronized int size() {//public方法都是synchronized修饰的。
        return count;
    }

	public synchronized V put(K key, V value) {
        // Make sure the value is not null
        if (value == null) {
            throw new NullPointerException();
        }

        // Makes sure the key is not already in the hashtable.
        Entry tab[] = table;
        int hash = hash(key);
        int index = (hash & 0x7FFFFFFF) % tab.length;//要存储的位置
        for (Entry<K,V> e = tab[index] ; e != null ; e = e.next) {
            if ((e.hash == hash) && e.key.equals(key)) {//hash值相等，key也相等，就会替换原来的值，并将原值返回。
                V old = e.value;
                e.value = value;
                return old;
            }
        }

        modCount++;
        if (count >= threshold) {
            // Rehash the table if the threshold is exceeded
            rehash();//重新设置table的长度

            tab = table;
            hash = hash(key);
            index = (hash & 0x7FFFFFFF) % tab.length;
        }

        // Creates the new entry.
        Entry<K,V> e = tab[index];
        tab[index] = new Entry<>(hash, key, value, e);
        count++;
        return null;
    }
	
	public synchronized V get(Object key) {
        Entry tab[] = table;
        int hash = hash(key);
        int index = (hash & 0x7FFFFFFF) % tab.length;
        for (Entry<K,V> e = tab[index] ; e != null ; e = e.next) {
            if ((e.hash == hash) && e.key.equals(key)) {
                return e.value;
            }
        }
        return null;
    }

	此外，它还有些KeySet等内部类，实现都与hashMap里面的差不多。

与hashMap不同的就是是，这个Hashtable不接受null的key和value。同时，它是线程安全的。

----------

#LinkedHashMap 类  #
类的声明：

public class LinkedHashMap<K,V>
    extends HashMap<K,V>
    implements Map<K,V>

API文档部分说明：

> Map 接口的哈希表和链接列表实现，具有可预知的迭代顺序。此实现与 HashMap 的不同之处在于，后者维护着一个运行于所有条目的双重链接列表。此链接列表定义了迭代顺序，该迭代顺序通常就是将键插入到映射中的顺序（插入顺序）。注意，如果在映射中重新插入 键，则插入顺序不受影响。（如果在调用 m.put(k, v) 前 m.containsKey(k) 返回了 true，则调用时会将键 k 重新插入到映射 m 中。）

> 此实现可以让客户避免未指定的、由 HashMap（及 Hashtable）所提供的通常为杂乱无章的排序工作，同时无需增加与 TreeMap 相关的成本。使用它可以生成一个与原来顺序相同的映射副本，而与原映射的实现无关：


----------
变量：
    
	/**
     * The head of the doubly linked list.
     */
	private transient Entry<K,V> header;//链表的头

	/**
     * The iteration ordering method for this linked hash map: <tt>true</tt>
     * for access-order, <tt>false</tt> for insertion-order.
     *
     * @serial
     */
    private final boolean accessOrder;

构造方法：

	public LinkedHashMap() {
		super();
		accessOrder = false;
	}

----------
其他方法：

	/**
	 * Called by superclass constructors and pseudoconstructors (clone,
	 * readObject) before any entries are inserted into the map. Initializes the
	 * chain.
	 */
	@Override
	void init() {//被父类调用
		header = new Entry<>(-1, null, null, null);
		header.before = header.after = header;//空的链表
	}
    

	//由于linkedHashMap是链表实现，所以转为newTable时，需要覆盖父类的方法
	void transfer(HashMap.Entry[] newTable, boolean rehash) {
		int newCapacity = newTable.length;
		for (Entry<K, V> e = header.after; e != header; e = e.after) {
			if (rehash)
				e.hash = (e.key == null) ? 0 : hash(e.key);
			int index = indexFor(e.hash, newCapacity);
			e.next = newTable[index];
			newTable[index] = e;
		}
	}


	/**
	 * This override differs from addEntry in that it doesn't resize the table
	 * or remove the eldest entry.
	 */
	void createEntry(int hash, K key, V value, int bucketIndex) {
		HashMap.Entry<K, V> old = table[bucketIndex];
		Entry<K, V> e = new Entry<>(hash, key, value, old);
		table[bucketIndex] = e;
		e.addBefore(header);
		size++;
	}

	//没有重写put方法，put方法是继承的父类HashMap的方法，只有get重写
	public V get(Object key) {
		Entry<K, V> e = (Entry<K, V>) getEntry(key);
		if (e == null)
			return null;
		e.recordAccess(this);
		return e.value;
	}

----------
Entry映射关系的实现：
	
	/**
	 * LinkedHashMap entry.
	 * 一定需要注意，它是继承的HashMap的Entry
	 */
	private static class Entry<K, V> extends HashMap.Entry<K, V> {
		// These fields comprise the doubly linked list used for iteration.
		Entry<K, V> before, after;//扩展两个指针

		Entry(int hash, K key, V value, HashMap.Entry<K, V> next) {
			super(hash, key, value, next);
		}

		/**
		 * Removes this entry from the linked list.
		 */
		private void remove() {//移除自己
			before.after = after;
			after.before = before;
		}

		/**
		 * Inserts this entry before the specified existing entry in the list.
		 * 把当前节点插入到existingEntry前面
		 */
		private void addBefore(Entry<K, V> existingEntry) {
			after = existingEntry;
			before = existingEntry.before;
			before.after = this;
			after.before = this;
		}

		/**
		 * This method is invoked by the superclass whenever the value of a
		 * pre-existing entry is read by Map.get or modified by Map.set. If the
		 * enclosing Map is access-ordered, it moves the entry to the end of the
		 * list; otherwise, it does nothing.
		 */
		void recordAccess(HashMap<K, V> m) {
			LinkedHashMap<K, V> lm = (LinkedHashMap<K, V>) m;
			if (lm.accessOrder) {//如果是插入的方式排序，这里就是false,不会做任何操作
				lm.modCount++;
				remove();
				addBefore(lm.header);
			}
		}

		void recordRemoval(HashMap<K, V> m) {
			remove();
		}
	}
	
为什么要这么实现，我觉得是因为如果想按照insert的顺序对map进行访问的话，hashMap是做不到的。
同时，treeMap的开销也挺高。因此，这个linkedHashMap就在hashMap的基础上，内部维护了一个链表接口，用户可以根据这个链表做到按序输出map中的值。

可以参考这篇博客：

[http://www.cnblogs.com/hzmark/archive/2012/12/26/LinkedHashMap.html](http://www.cnblogs.com/hzmark/archive/2012/12/26/LinkedHashMap.html "LinkedHashMap")

写的还不错。

----------
