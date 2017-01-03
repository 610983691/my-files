#Set 接口#

public interface Set<E> extends Collection<E>

类的API声明：
一个不包含重复元素的 collection。更确切地讲，set 不包含满足 e1.equals(e2) 的元素对 e1 和 e2，并且最多包含一个 null 元素。正如其名称所暗示的，此接口模仿了数学上的 set 抽象。

----------
## AbstractSet 抽象类##
类声明：
public abstract class AbstractSet<E> extends AbstractCollection<E> implements Set<E>

> 此类提供 Set 接口的骨干实现，从而最大限度地减少了实现此接口所需的工作。

> 通过扩展此类来实现一个 set 的过程与通过扩展 AbstractCollection 来实现 Collection 的过程是相同的，除了此类的子类中的所有方法和构造方法都必须服从 Set 接口所强加的额外限制（例如，add 方法必须不允许将一个对象的多个实例添加到一个 set 中）。

> 注意，此类并没有重写 AbstractCollection 类中的任何实现。它仅仅添加了 equals 和 hashCode 的实现。

下面是两个添加的实现方法：
    public boolean equals(Object o) {
        if (o == this)
            return true;

        if (!(o instanceof Set))
            return false;
        Collection c = (Collection) o;//用Set不行吗 ？
        if (c.size() != size())
            return false;
        try {
            return containsAll(c);//如果集合c中的元素在set中存在，就认为相等
        } catch (ClassCastException unused)   {
            return false;
        } catch (NullPointerException unused) {
            return false;
        }
    }

	public int hashCode() {//哈希码是元素的哈希码之和
        int h = 0;
        Iterator<E> i = iterator();
        while (i.hasNext()) {
            E obj = i.next();
            if (obj != null)
                h += obj.hashCode();
        }
        return h;
    }

	public boolean removeAll(Collection<?> c) {
        boolean modified = false;

        if (size() > c.size()) {
            for (Iterator<?> i = c.iterator(); i.hasNext(); )
                modified |= remove(i.next());
        } else {
            for (Iterator<?> i = iterator(); i.hasNext(); ) {
                if (c.contains(i.next())) {
                    i.remove();
                    modified = true;
                }
            }
        }
        return modified;
    }

总的来说，这个类就是Set的主要实现，跟其他的AbstractList之类一样。


----------
## HashSet ##
public class HashSet<E>
    extends AbstractSet<E>
    implements Set<E>, Cloneable, java.io.Serializable

此类实现 Set 接口，由哈希表（实际上是一个 HashMap 实例）支持。它不保证 set 的迭代顺序；特别是它不保证该顺序恒久不变。此类允许使用 null 元素。

注意，此实现不是同步的。

> 我是万万没想到，竟然里面用HashMap来实现的。


----------
首先看看它的字段：

     private transient HashMap<E,Object> map;

    // Dummy value to associate with an Object in the backing Map
    private static final Object PRESENT = new Object();//map中的值都是这个

然后是构造方法：

	public HashSet() {
        map = new HashMap<>();
    }
	public HashSet(Collection<? extends E> c) {
        map = new HashMap<>(Math.max((int) (c.size()/.75f) + 1, 16));
        addAll(c);
    }
	public HashSet(int initialCapacity, float loadFactor) {
        map = new HashMap<>(initialCapacity, loadFactor);
    }
	public HashSet(int initialCapacity) {
        map = new HashMap<>(initialCapacity);
    }
这就很明显了，HashSet本质上就是一个hashMap.再看看它的add方法，就会更加的清楚：

    public boolean add(E e) {
        return map.put(e, PRESENT)==null;//这样的话，map中的每个key对应的value都是PRESENT，而且这个对象还是static final的。
    }

	public boolean remove(Object o) {
        return map.remove(o)==PRESENT;
    }

	public Iterator<E> iterator() {
        return map.keySet().iterator();//必须是keySet，因为set的值就是map中的key.
    }


----------
# TreeSet 类 #
public class TreeSet<E> extends AbstractSet<E>
    implements NavigableSet<E>, Cloneable, java.io.Serializable
同样，这个类也是基于TreeMap来实现的，---这里也跟TreeMap一样，TreeSet的元素类型必须实现Compareable接口
代码：
    
 	private transient NavigableMap<E,Object> m;
	private static final Object PRESENT = new Object();

	public TreeSet() {
        this(new TreeMap<E,Object>());
    }
	TreeSet(NavigableMap<E,Object> m) {
        this.m = m;
    }

	public TreeSet(Comparator<? super E> comparator) {
        this(new TreeMap<>(comparator));
    }

	public TreeSet(Collection<? extends E> c) {
        this();
        addAll(c);
    }

	public boolean add(E e) {
        return m.put(e, PRESENT)==null;
    }

----------
运行如下代码，也会发现抛出异常。就是因为TestTreeMap 没有实现compareble接口导致的。

    TreeSet<TestTreeMap> set = new TreeSet<TestTreeMap>();
		set.add(t1);
		set.add(t2);


----------
