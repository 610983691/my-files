参考文献：

[https://www.ibm.com/developerworks/cn/java/j-lo-jdk8newfeature/index.html](https://www.ibm.com/developerworks/cn/java/j-lo-jdk8newfeature/index.html "java8特性")

##函数式接口
@FunctionalInterface

函数式接口的重要属性是：我们能够使用 Lambda 实例化它们，Lambda 表达式让你能够将函数作为方法参数，或者将代码作为数据对待。

##lambda表达式


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



##接口增强

default方法的使用，

接口看起来和抽象类更像了。 


##流式操作
Stream和Collection区别
