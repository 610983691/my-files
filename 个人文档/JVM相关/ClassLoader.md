参考文章：

http://www.blogjava.net/zhuxing/archive/2008/08/08/220841.html

##总结1：

我们首先看一下JVM预定义的三种类型类加载器，当一个 JVM 启动的时候，Java 缺省开始使用如下三种类型类装入器：

**启动（Bootstrap）类加载器**：引导类装入器是用本地代码实现的类装入器，它负责将 <Java_Runtime_Home>/lib 下面的类库加载到内存中。由于引导类加载器涉及到虚拟机本地实现细节，开发者无法直接获取到启动类加载器的引用，所以不允许直接通过引用进行操作。

**标准扩展（Extension）类加载器**：扩展类加载器是由 Sun 的 ExtClassLoader（sun.misc.Launcher$ExtClassLoader） 实现的。它负责将 < Java_Runtime_Home >/lib/ext 或者由系统变量 java.ext.dir 指定位置中的类库加载到内存中。开发者可以直接使用标准扩展类加载器。

**系统（System）类加载器：**系统类加载器是由 Sun 的 AppClassLoader（sun.misc.Launcher$AppClassLoader）实现的。它负责将系统类路径（CLASSPATH）中指定的类库加载到内存中。开发者可以直接使用系统类加载器。


##类加载器的继承关系：
    
	//负责加载jre/lib/ext下的jar包(在我系统中就是JAVA_HOME/jre/lib/ext/目录下的jar包)
	ExtClassLoader -> UrlClassLoader -> SecureClassLoader ->  java.lang.ClassLoader ->Object

	//负责加载Class_Path指定的类库（我的系统中就是JAVA_HOME/lib/dt.jar;JAVA_HOME/lib/tools.jar）
	AppClassLoader -> UrlClassLoader -> SecureClassLoader ->  java.lang.ClassLoader ->Object


###java.lang.ClassLoader类

根据网上的资料，自己也看下源码，主要要了解加载过程。网上普遍认为，不应当改变loadClass方法的加载逻辑，

	//最重要的loadClass方法，根据包路径名称来加载该类
	public Class<?> loadClass(String name) throws ClassNotFoundException {
        return loadClass(name, false);
    }

	//该方法包含了默认的加载策略（就是前边说的双亲委派机制）
	protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException
    {
        synchronized (getClassLoadingLock(name)) {
            // First, check if the class has already been loaded
            Class c = findLoadedClass(name);
            if (c == null) {
                long t0 = System.nanoTime();
                try {
                    if (parent != null) {//让双亲加载器去加载
                        c = parent.loadClass(name, false);
                    } else {
                        c = findBootstrapClassOrNull(name);//没有双亲就要看系统的启动加载器有没有加载这个类
                    }
                } catch (ClassNotFoundException e) {
                    // ClassNotFoundException thrown if class not found
                    // from the non-null parent class loader
                }

                if (c == null) {
                    // If still not found, then invoke findClass in order
                    // to find the class.
                    long t1 = System.nanoTime();
					//注意，在ClassLoder里边findClass方法返回异常，意味着子类需要按照自己的需求去找这个类。
                    c = findClass(name);

                    // this is the defining class loader; record the stats
                    sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                    sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                    sun.misc.PerfCounter.getFindClasses().increment();
                }
            }
            if (resolve) {
                resolveClass(c);
            }
            return c;
        }
    }

	protected Class<?> findClass(String name) throws ClassNotFoundException {
        throw new ClassNotFoundException(name);
    }

	//解析这个类
	protected final void resolveClass(Class<?> c) {
        resolveClass0(c);
    }

    private native void resolveClass0(Class c);

	
	protected final Class<?> findLoadedClass(String name) {
        if (!checkName(name))
            return null;
        return findLoadedClass0(name);
    }

    private native final Class findLoadedClass0(String name);


###UrlClassLoader


	/**
	* 这个类重写了findClass方法，可以看出传的参数是类似lang.test.Test这样的类名
	* 方法里边自动替换.为/，并且加上了.class后缀名
	*/
	protected Class<?> findClass(final String name)
         throws ClassNotFoundException
    {
        try {
            return AccessController.doPrivileged(
                new PrivilegedExceptionAction<Class>() {
                    public Class run() throws ClassNotFoundException {
                        String path = name.replace('.', '/').concat(".class");
                        Resource res = ucp.getResource(path, false);
                        if (res != null) {
                            try {
                                return defineClass(name, res);//类的定义，里边会调用一些本地方法来加载字节码
                            } catch (IOException e) {
                                throw new ClassNotFoundException(name, e);
                            }
                        } else {
                            throw new ClassNotFoundException(name);
                        }
                    }
                }, acc);
        } catch (java.security.PrivilegedActionException pae) {
            throw (ClassNotFoundException) pae.getException();
        }
    }

####测试：

1.测试系统类加载器
	
	public static void main(String[] s) throws Exception {
		// 调用加载当前类的类加载器（这里即为系统类加载器）加载Test
		Class typeLoaded = Class.forName("lang.classload.Test");
		System.out.println(typeLoaded.getName());
		// 查看被加载的TestBean类型是被那个类加载器加载的
		System.out.println(typeLoaded.getClassLoader());
	}
	输出：
	lang.classload.Test
	sun.misc.Launcher$AppClassLoader@1471cb25
2.测试标准扩展加载器

按照文章中的示例，将Test.class打jar包放到JAVA_HOME/jre/lib/ext/路径下，并再次运行上述代码，输出如下：

	//Test.class文件打jar包后放到JAVA_HOME/jre/lib/ext/路径下，输出：
	lang.classload.Test
	sun.misc.Launcher$ExtClassLoader@47415dbf

这就很好的说明了，ExtClassLoader是AppClassLoader的父类，因为只有它是父类的时候，才会在AppClassLoader加载前加载Test.class

3.测试Bootstrap加载器:


	将test.jar拷贝一份到< Java_Runtime_Home >/lib下，运行测试代码，输出如下：

	sun.misc.Launcher$ExtClassLoader@7259da

> 这是因为，虽然BootStrap类加载器是ExtClassLoader的父类，但是java出于安全的考虑，不允许加载JAVA_HOME/jre/lib/路径下陌生的文件。（怀疑虚拟机里边写好了的?）


###自定义类加载器:

	