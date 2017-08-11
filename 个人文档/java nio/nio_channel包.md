#channel 包

#Channel接口
接口的声明，接口中总共就两个方法，一个方法用于判断
	
	public interface Channel extends Closeable{}

	/**
     * Tells whether or not this channel is open.  </p>
     *
     * @return <tt>true</tt> if, and only if, this channel is open
     */
    public boolean isOpen();

	/**
     * Closes this channel.
     *
     * <p> After a channel is closed, any further attempt to invoke I/O
     * operations upon it will cause a {@link ClosedChannelException} to be
     * thrown.
     *
     * <p> If this channel is already closed then invoking this method has no
     * effect.
     *
     * <p> This method may be invoked at any time.  If some other thread has
     * already invoked it, however, then another invocation will block until
     * the first invocation is complete, after which it will return without
     * effect. </p>
     *
     * @throws  IOException  If an I/O error occurs
     */
    public void close() throws IOException;


#ReadableByteChannel
查看API文档，该接口的设计是：
可读取字节的通道。

在任意给定时刻，一个可读取通道上只能进行一个读取操作。如果某个线程在通道上发起读取操作，那么在第一个操作完成之前，将阻塞其他所有试图发起另一个读取操作的线程。其他种类的 I/O 操作是否继续与读取操作并发执行取决于该通道的类型。
查看接口声明，直接继承了基本的Channel接口

	public interface ReadableByteChannel extends Channel 
	
	//将字节序列从此通道中读入给定的缓冲区。
	public int read(ByteBuffer dst) throws IOException;


#WritableByteChannel
查看API文档：
可写入字节的通道。

在任意给定时刻，一个可写入通道上只能进行一个写入操作。如果某个线程在通道上发起写入操作，那么在第一个操作完成之前，将阻塞其他所有试图发起另一个写入操作的线程。其他种类的 I/O 操作是否继续与写入操作并发执行则取决于该通道的类型。


	public interface WritableByteChannel extends Channel

方法：
	
	/**
	*该方法是将字节序列从给定的缓冲区中写入此通道。
    *尝试最多向该通道中写入 r 个字节，其中 r 是调用此方法时缓冲区中剩余的字节数，即 *src.remaining()。
	*/	
	public int write(ByteBuffer src) throws IOException;


#ByteChannel

可读取和写入字节的信道。此接口只是统一了 ReadableByteChannel 和 WritableByteChannel；它没有指定任何新操作。

	public interface ByteChannel
    extends ReadableByteChannel, WritableByteChannel

#GatheringByteChannel
API文档描述：

可从缓冲区序列写入字节的通道。

集中 写入操作可在单个调用中写入来自一个或多个给定缓冲区序列的字节序列。集中写入通常在实现网络协议或文件格式时很有用，例如将数据分组放入段中（这些段由一个或多个长度固定的头，后跟长度可变的正文组成）。在 ScatteringByteChannel 接口中定义了类似的分散 读取操作。

根据接口中扩展的两个接口可以看出，它能实现 将多个byteBuffer缓冲区的字节序写入到通道。

	public interface GatheringByteChannel extends WritableByteChannel

方法：

	/**
	*将字节序列从给定缓冲区的子序列写入此通道。
	*尝试最多向此通道中写入 r 个字节，其中 r 是给定缓冲区数组的指定子序列中剩余的字节数，也就是
	* srcs[offset].remaining()
    * + srcs[offset+1].remaining()
    * + ... + srcs[offset+length-1].remaining()
	*/
	public long write(ByteBuffer[] srcs, int offset, int length)
        throws IOException;

	//因为一个ByteBuffer就是int的，所以Bytebuffer[]的长度可能>integer.maxvalue,这里用long
	public long write(ByteBuffer[] srcs) throws IOException;

#ScatteringByteChannel

	public interface ScatteringByteChannel extends ReadableByteChannel

API文档描述：
	可将字节读入缓冲区序列的通道。

分散 读取操作可在单个调用中将一个字节序列读入一个或多个给定的缓冲区序列。分散读取通常在实现网络协议或文件格式时很有用，例如将数据分组放入段中（这些段由一个或多个长度固定的头，后跟长度可变的正文组成）。在 GatheringByteChannel 接口中定义了类似的集中 写入操作。

方法：

	/*
	* 将字节序列从此通道读入给定缓冲区的子序列中。
	* 
	*调用此方法会尝试最多从此通道读取 r 个字节，其中 r 是给定缓冲区数组的指定子序列中剩余的字节数，也就是
	* dsts[offset].remaining()
    * + dsts[offset+1].remaining()
    * + ... + dsts[offset+length-1].remaining()
	*/
	public long read(ByteBuffer[] dsts, int offset, int length)
        throws IOException;

	public long read(ByteBuffer[] dsts) throws IOException;

#NetworkChannel
网络套接字的通道
	
	/**
	*A channel to a network socket.
	*/
	public interface NetworkChannel extends Channel

方法：
	
	/**
	*Binds the channel's socket to a local address.
	* local为null是，bind到一个自动分配的地址
	**/
	NetworkChannel bind(SocketAddress local) throws IOException;
	
	/**
	* Sets the value of a socket option.
	*/
	<T> NetworkChannel setOption(SocketOption<T> name, T value) throws IOException;

	/**
     * Returns a set of the socket options supported by this channel.
     *
     * <p> This method will continue to return the set of options even after the
     * channel has been closed.
     *
     * @return  A set of the socket options supported by this channel
     */
    Set<SocketOption<?>> supportedOptions();

#SeekableByteChannel
API文档的接口描述：

	
	/*A byte channel that maintains a current <i>position</i> and allows the
 	* position to be changed.
 	* 其中包含了读写的方法，
 	* /
	public interface SeekableByteChannel extends ByteChannel

方法：

	/**
	* Reads a sequence of bytes from this channel into the given buffer.
	*/
	int read(ByteBuffer dst) throws IOException;
#FileChannel
API文档描述：
	用于读取、写入、映射和操作文件的通道
	多个并发线程可安全地使用文件通道。
public abstract class FileChannel
    extends AbstractInterruptibleChannel
    implements SeekableByteChannel, GatheringByteChannel, ScatteringByteChannel

方法:

	/*
	* @since   1.7
	* 提供一个获取FileChannel的实例
     */
    public static FileChannel open(Path path,
                                   Set<? extends OpenOption> options,
                                   FileAttribute<?>... attrs)
        throws IOException
    {
        FileSystemProvider provider = path.getFileSystem().provider();
        return provider.newFileChannel(path, options, attrs);
    }

	/*
	* 创建一个文件，并且返回一个访问该文件的通道。
	* @since   1.7
     */
    public static FileChannel open(Path path, OpenOption... options)
        throws IOException
    {
        Set<OpenOption> set = new HashSet<OpenOption>(options.length);
        Collections.addAll(set, options);
        return open(path, set, NO_ATTRIBUTES);
    }
	
	/**
	* 用于截断文件
	* 注意，如果是截断文件并且position>size，那么position会被设置为 size.
	*/
	public abstract FileChannel truncate(long size) throws IOException;

	/**
	* 强制将所有对此通道的文件更新写入包含该文件的存储设备中。
	* 这个会将修改写入到硬盘。
	* boolean参数为true 时，会修改文件时间等元数据(文件属性)。fasle只修改文件的内容
	*/
	public abstract void force(boolean metaData) throws IOException;

	/**
	* 将字节从此通道的文件传输到给定的可写字节通道。
	*/
	public abstract long transferTo(long position, long count,
                                    WritableByteChannel target)
        throws IOException;
	/**
	* 从给定的可读字节将字节传输到该通道的文件中。
	*/
	public abstract long transferFrom(ReadableByteChannel src,
                                      long position, long count)
        throws IOException;

#SelectableChannel
被设计用来给Selectors 使用的可选择通道。
API文档：

新创建的可选择通道总是处于阻塞模式。在结合使用基于选择器的多路复用时，非阻塞模式是最有用的。向选择器注册某个通道前，必须将该通道置于非阻塞模式，并且在注销之前可能无法返回到阻塞模式。

方法：

	/**
     * Returns the provider that created this channel.
     *
     * @return  The provider that created this channel
     */
    public abstract SelectorProvider provider();

	//判断该通道是否被注册过
	public abstract boolean isRegistered();

	//判断给定的sel中是否注册了该通道，如果有就返回对应的key,否则返回null.
	public abstract SelectionKey keyFor(Selector sel);

	//注册到给定的selector中
	public abstract SelectionKey register(Selector sel, int ops, Object att)
        throws ClosedChannelException;

	//调整该通道的阻塞模式，如果block为true并且已经注册过，那么抛出异常。
	public abstract SelectableChannel configureBlocking(boolean block)
        throws IOException;

	//判断通道是否阻塞模式
	public abstract boolean isBlocking();

	//获取阻塞锁
	public abstract Object blockingLock();

#Selector
API文档:

SelectableChannel 对象的多路复用器。	
	