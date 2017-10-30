参考文献：

[https://www.ibm.com/developerworks/cn/java/j-lo-jdk8newfeature/index.html](https://www.ibm.com/developerworks/cn/java/j-lo-jdk8newfeature/index.html "java8特性")


函数式编程的特性及场景：

[http://www.cnblogs.com/wangxin37/p/6737522.html](http://www.cnblogs.com/wangxin37/p/6737522.html "lambda表达式应用场景")
##函数式接口
@FunctionalInterface

函数式接口的重要属性是：我们能够使用 Lambda 实例化它们，Lambda 表达式让你能够将函数作为方法参数，或者将代码作为数据对待。

##lambda表达式

语法：
	
	1. 方法体为表达式，该表达式的值作为返回值返回。--这里就不用显示的写return
	(parameters) -> expression

	2. 方法体为代码块，必须用 {} 来包裹起来，且需要一个 return 返回值，但若函数式接口里面方法返回值是 void，则无需返回值。
	
	//{}statemnts里边需要由return 语句，有显示的return.
	(parameters) -> { statements; };//需要带分号
	
实例：


	//一个函数式接口
	public interface FeatureInterface extends Runnable {
	}

	//用lambda表达式来创建线程：
	FeatureInterface f = () -> System.out.println("123");
	f.run();
lambda方式的编译结果：
![](/lambda.PNG)

	//java8之前创建这个线程的方式
	FeatureInterface f = new FeatureInterface() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				
			}
		};
//查看编译结果：
![](/classical.PNG)

总结上面两个图片，可以知道。传统的方式中，直接 new接口的话，相当于是传递了一个匿名内部类来实现的。
而使用lambda表达式的方式来创建这个函数式接口则看不到任何匿名内部类的痕迹。

###函数式通用接口
函数式通用接口在java8中新增的java.util.function.*包下

要使用 Lambda 表达式，需要定义一个函数式接口，这样往往会让程序充斥着过量的仅为 Lambda 表达式服务的函数式接口。为了减少这样过量的函数式接口，Java 8 在 java.util.function 中增加了不少新的函数式通用接口。

###Predicate的使用：

	public static void main(String args[]) {
		List<Integer> list = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9);

		// Predicate<Integer> predicate = n -> true
		// n 是一个参数传递到 Predicate 接口的 test 方法
		// n 如果存在则 test 方法返回 true

		System.out.println("输出所有数据:");

		// 传递参数 n
		eval(list, n -> true);

		// 自定义的predicate的实现
		Predicate<Integer> predicate = m -> {
			System.out.println(m + "%3=" + m % 3);
			return m % 3 == 0;
		};
		predicate.test(2);

	}

	//网上例子
	public static void eval(List<Integer> list, Predicate<Integer> predicate) {
		for (Integer n : list) {

			if (predicate.test(n)) {
				System.out.println(n + " ");
			}
		}
	}

Predicate接口的使用，不一定好用，但我觉得可以应用到该场景。
场景：接口参数的校验

	Predicate<Dto> consumer = param -> {
			if (param.getLevel().equals("high") && param.getScore() > 0) {
				return true;
			} else {
				return false;
			}
		};
	consumer.test(new Dto());
只是一种使用的方式， 这种使用方式不见得就好。

###在lambda表达式中加入Predicate

网上的使用场景实例：

上个例子说到，java.util.function.Predicate 允许将两个或更多的 Predicate 合成一个。它提供类似于逻辑操作符AND和OR的方法，名字叫做and()、or()和xor()，用于将传入 filter() 方法的条件合并起来。例如，要得到所有以J开始，长度为四个字母的语言，可以定义两个独立的 Predicate 示例分别表示每一个条件，然后用 Predicate.and() 方法将它们合并起来，如下所示：

// 甚至可以用and()、or()和xor()逻辑函数来合并Predicate，
// 例如要找到所有以J开始，长度为四个字母的名字，你可以合并两个Predicate并传入

	Predicate<String> startsWithJ = (n) -> n.startsWith("J");
	Predicate<String> fourLetterLong = (n) -> n.length() == 4;
	names.stream()
	    .filter(startsWithJ.and(fourLetterLong))
	    .forEach((n) -> System.out.print("nName, which starts with 'J' and four letter long is : " + n));


lambda表达式使用;

	private static void mapAndReduce() {
		// 不使用lambda表达式为每个订单加上12%的税
		List<Integer> costBeforeTax = Arrays.asList(100, 200, 300, 400, 500);
		for (Integer cost : costBeforeTax) {
			double price = cost + .12 * cost;
			System.out.println(price);
		}

		// 使用lambda表达式
		List<Integer> costBeforeTax2 = Arrays.asList(100, 200, 300, 400, 500);
		costBeforeTax2.stream().map((cost2) -> cost2 + .12 * cost2)
				.forEach(System.out::println);
		// 这两个等价
		costBeforeTax2.stream()
				.forEach(cost2 -> System.out.println(cost2 + .12 * cost2));
	}

##Iterator.foreach()
java8中Iterator接口中新增了一个forEach方法，源码如下：

	default void forEach(Consumer<? super T> action) {
        Objects.requireNonNull(action);
        for (T t : this) {
            action.accept(t);
        }
    }

外面可以传递一个Consumer接口的实现，来对一个集合实现遍历操作。

	//例子，对list做一次遍历。遍历过程中需要做的就是输出这个对象的值，toString（）.
	public class ListTest {
	
		public static void main(String[] a) throws Exception {
			List list = Arrays.asList(1, 2, 3, 4, "5", new ListTest());
			list.forEach(s -> System.out.println(s));
	
		}
	}

	public static void filter(List<String> names, Predicate<String> condition) {
		// 链式操作特性+流特性+forEach
		names.stream().filter(condition).forEach((name) -> {
			System.out.println(name + " ");
		});
	}



##接口增强

default方法的使用，

接口看起来和抽象类更像了。 


##流式操作
Stream和Collection区别

##

总的来说，lambda表达式让业务更抽象，也更简单。

后续自己学习项目中使用java8开发，这样自己也更加熟悉。
