##
在java nio包中，所有的buffer类大概可以分为两类，public 的和default的。而所有的public 的bufferr类都是抽象类。
所以我觉得，这些ByteBuffer,DoubleBuffer类是不建议直接实例化来使用的。
而是应该使用相应的方法来获取buffer，然后调用其public方法。
提供了静态的allocate(int)方法来获取buffer缓冲区的实例。


##Buffer
查看类的声明，这个buffer就是指定类型数据的一个容器而已。是nio包中charBuffer，bytebuffer等的父类。

	//A container for data of a specific primitive type
	public abstract class Buffer {}
重要字段

	// Invariants: 0<=mark <= position <= limit <= capacity
    private int mark = -1;
    private int position = 0;
    private int limit;
    private int capacity;

以ByteBuffer为例：
####ByteBuffer
类声明
    
	public abstract class ByteBuffer
    extends Buffer
    implements Comparable<ByteBuffer>{}

bytebuffer中的字段描述

	// These fields are declared here rather than in Heap-X-Buffer in order to
    // reduce the number of virtual method invocations needed to access these
    // values, which is especially costly when coding small buffers.
    //
    final byte[] hb;                  // Non-null only for heap buffers
    final int offset;
    boolean isReadOnly;                 // Valid only for heap buffers

bytebuffer的实例化方法：

    
 	public static ByteBuffer allocateDirect(int capacity) {
        return new DirectByteBuffer(capacity);
    }
> 因为ByteBuffer是一个抽象类，所以不能被new等方式实例化。因此提供了静态的方法来获取相应的bytebuffer实例
> 
> **java文档**
>
直接与非直接缓冲区
>
字节缓冲区要么是直接的，要么是非直接的。如果为直接字节缓冲区，则 Java 虚拟机会尽最大努力直接在此缓冲区上执行本机 I/O 操作。也就是说，在每次调用基础操作系统的一个本机 I/O 操作之前（或之后），虚拟机都会尽量避免将缓冲区的内容复制到中间缓冲区中（或从中间缓冲区中复制内容）。
直接字节缓冲区可以通过调用此类的 allocateDirect 工厂方法来创建。*此方法返回的缓冲区进行分配和取消分配所需成本通常高于非直接缓冲区*。直接缓冲区的内容可以驻留在常规的垃圾回收堆之外，因此，它们对应用程序的内存需求量造成的影响可能并不明显。所以，*建议将直接缓冲区主要分配给那些易受基础系统的本机 I/O 操作影响的大型、持久的缓冲区*。一般情况下，*最好仅在直接缓冲区能在程序性能方面带来明显好处时分配它们*。

