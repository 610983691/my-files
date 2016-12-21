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
