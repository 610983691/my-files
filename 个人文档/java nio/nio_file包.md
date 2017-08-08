#Files

###1.文件操作类，提供了copy,move,delete等一系列的文件操作类方法。需要注意的是，该类的构造方法是私有的，因此它设计为不能被实例化。所以，该类不像I/O中的File 类，这个Files类更像是一个文件类型操作的工具方法。
##类的声明：
public final class Files


##构造方法:
private Files() { }

##常用方法：

	/**
     * Returns the {@code FileSystemProvider} to delegate to.
     * 该方法返回了一个FileSystemProvider  ，可见Files类一般操作的都是Path.
     * 这个Path我觉得可以理解为I/O中的 File.
     */
    private static FileSystemProvider provider(Path path) {
        return path.getFileSystem().provider();
    }

	/**
	该方法返回一个Path所指定文件的输入流，默认操作是READ。
	流是线程安全的
	我觉得对比与IO，这个操作类似于 new fileInputStream(File).
	更多的方法介绍，可参考API文档，这里不详细写了。
	*/
	public static InputStream newInputStream(Path path, OpenOption... options)
        throws IOException
    {
        return provider(path).newInputStream(path, options);
    }

	/**
	* 查看方法的返回值和方法名，更加印证了在Nio中，File--Path的对应关系。
	*/
	 public static Path createFile(Path path, FileAttribute<?>... attrs)
        throws IOException
    {
        EnumSet<StandardOpenOption> options =
            EnumSet.<StandardOpenOption>of(StandardOpenOption.CREATE_NEW, StandardOpenOption.WRITE);
        newByteChannel(path, options, attrs).close();
        return path;
    }

##FileSystemProvider
Files类的操作，几乎都是通过FileSystemProvider类来实现的。
而这个FileSystemProvider 是抽象的，它的实现是通过下面FileSystems里边调用sun.的包中的构造方法，并通过本地方法来实现的。
	
 		// returns default provider
        private static FileSystemProvider getDefaultProvider() {
            FileSystemProvider provider = sun.nio.fs.DefaultFileSystemProvider.create();

            // if the property java.nio.file.spi.DefaultFileSystemProvider is
            // set then its value is the name of the default provider (or a list)
            String propValue = System
                .getProperty("java.nio.file.spi.DefaultFileSystemProvider");
            if (propValue != null) {
                for (String cn: propValue.split(",")) {
                    try {
                        Class<?> c = Class
                            .forName(cn, true, ClassLoader.getSystemClassLoader());
                        Constructor<?> ctor = c
                            .getDeclaredConstructor(FileSystemProvider.class);
                        provider = (FileSystemProvider)ctor.newInstance(provider);

                        // must be "file"
                        if (!provider.getScheme().equals("file"))
                            throw new Error("Default provider must use scheme 'file'");

                    } catch (Exception x) {
                        throw new Error(x);
                    }
                }
            }
            return provider;
        }
    }
	

##FileSystem
public abstract class FileSystem{}；
这个类提供了一系列的抽象方法，每个方法都是抽象的。	

	/**
     * Returns the provider that created this file system.
     * 该方法很重要，虽然在这里没有实现。但它是在sun的包/或者native方法里边实现的。
     * @return  The provider that created this file system.
     */
    public abstract FileSystemProvider provider();

	/**
	*从文件系统里边获取一个Path对象的实例.Path的实例化也是底层实现的。
	*/
	public abstract Path getPath(String first, String... more);
	
##FileSystems

FileSystems 类是FileSystem的工厂类。在FileSystems类中，以私有内部类的方式实现单例的DefaultFileSystem.代码如下：

	
	public static FileSystem getDefault() {
        return DefaultFileSystemHolder.defaultFileSystem;
    }

	// lazy initialization of default file system
    private static class DefaultFileSystemHolder {
        static final FileSystem defaultFileSystem = defaultFileSystem();

        // returns default file system
        private static FileSystem defaultFileSystem() {
            // load default provider
            FileSystemProvider provider = AccessController
                .doPrivileged(new PrivilegedAction<FileSystemProvider>() {
                    public FileSystemProvider run() {
                        return getDefaultProvider();
                    }
                });

            // return file system
            return provider.getFileSystem(URI.create("file:///"));
        }

        // returns default provider
        private static FileSystemProvider getDefaultProvider() {
            FileSystemProvider provider = sun.nio.fs.DefaultFileSystemProvider.create();

            // if the property java.nio.file.spi.DefaultFileSystemProvider is
            // set then its value is the name of the default provider (or a list)
            String propValue = System
                .getProperty("java.nio.file.spi.DefaultFileSystemProvider");
            if (propValue != null) {
                for (String cn: propValue.split(",")) {
                    try {
                        Class<?> c = Class
                            .forName(cn, true, ClassLoader.getSystemClassLoader());
                        Constructor<?> ctor = c
                            .getDeclaredConstructor(FileSystemProvider.class);
                        provider = (FileSystemProvider)ctor.newInstance(provider);

                        // must be "file"
                        if (!provider.getScheme().equals("file"))
                            throw new Error("Default provider must use scheme 'file'");

                    } catch (Exception x) {
                        throw new Error(x);
                    }
                }
            }
            return provider;
        }
    }
	
	
#Path
这是个接口，类似于File.

#Paths 
Paths类是Path的工厂类，提供Path的实现。

	//该方法是通过FileSystem的getPath来获取Path实例
	//注意，more参数意味着实际的path是：first/more1/more2
	public static Path get(String first, String... more) {
        return FileSystems.getDefault().getPath(first, more);
    }

	/**
	*
	*/
	public static Path get(URI uri) {
        String scheme =  uri.getScheme();
        if (scheme == null)
            throw new IllegalArgumentException("Missing scheme");

        // check for default provider to avoid loading of installed providers
        if (scheme.equalsIgnoreCase("file"))
            return FileSystems.getDefault().provider().getPath(uri);

        // try to find provider
        for (FileSystemProvider provider: FileSystemProvider.installedProviders()) {
            if (provider.getScheme().equalsIgnoreCase(scheme)) {
                return provider.getPath(uri);
            }
        }

        throw new FileSystemNotFoundException("Provider \"" + scheme + "\" not installed");
    }

#FileStore
类的描述,文件存储。
	
	/**
	 * Storage for files. A {@code FileStore} represents a storage pool, device,
	 * partition, volume, concrete file system or other implementation specific means
	 * of file storage. The {@code FileStore} for where a file is stored is obtained
	 * by invoking the {@link Files#getFileStore getFileStore} method, or all file
	 * stores can be enumerated by invoking the {@link FileSystem#getFileStores
	 * getFileStores} method.
	 *
	 * <p> In addition to the methods defined by this class, a file store may support
	 * one or more {@link FileStoreAttributeView FileStoreAttributeView} classes
	 * that provide a read-only or updatable view of a set of file store attributes.
	 *
	 * @since 1.7
	 */
