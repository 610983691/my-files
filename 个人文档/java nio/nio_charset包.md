#Charset包
查看API的包描述:
Charset	16 位的 Unicode 代码单元序列和字节序列之间的指定映射关系。
CharsetDecoder	能够把特定 charset 中的字节序列转换成 16 位 Unicode 字符序列的引擎。
CharsetEncoder	能够把 16 位 Unicode 字符序列转换成特定 charset 中字节序列的引擎。
CoderResult	coder 结果状态的描述。
CodingErrorAction	编码错误操作的类型安全的枚举。

#Charset类
API文档描述如下：
> 
16 位的 Unicode 代码单元序列和字节序列之间的指定映射关系。此类定义了用于创建解码器和编码器以及获取与 charset 关联的各种名称的方法。此类的实例是不可变的。
>
此类也定义了用于测试是否支持特定 charset 的静态方法、通过名称查找 charset 实例的静态方法，以及构造一个包含目前 Java 虚拟机支持的每个 charset 的映射静态方法。通过类 CharsetProvider 中定义的服务提供者接口可以添加对新 charset 的支持。
>
此类中定义的所有方法用于多个并发线程是安全的。 



###标准 charset

Java 平台的每一种实现都需要支持以下标准 charset。请参考该实现的版本文档，查看是否支持其他 charset。这些可选 charset 的行为在不同的实现之间可能有所不同。

Charset

描述

- US-ASCII	7 位 ASCII 字符，也叫作 ISO646-US、Unicode 字符集的基本拉丁块
- ISO-8859-1  	ISO 拉丁字母表 No.1，也叫作 ISO-LATIN-1
- UTF-8	8 位 UCS 转换格式
- UTF-16BE	16 位 UCS 转换格式，Big Endian（最低地址存放高位字节）字节顺序
- UTF-16LE	16 位 UCS 转换格式，Little-endian（最高地址存放低位字节）字节顺序
- UTF-16	16 位 UCS 转换格式，字节顺序由可选的字节顺序标记来标识

#CharsetEncoder
能够把 16 位 Unicode 字符序列转换成特定 charset 中字节序列的引擎。 

##构造方法

	/**
	* 初始化新的编码器。新编码器具有给定的每字符多少个字节 (chars-per-byte) 值和替换值。
	* 参数：
	* averageBytesPerChar - 一个正的 float 值，指示为每个输入字符所生成的字节数
	* maxBytesPerChar - 一个正的 float 值，指示为每个输入字符所生成的最大字节数
	* replacement - 初始替换值；一定不能为 null、必须具有非零长度、必须小于
	*  maxBytesPerChar，并且必须为 legal
	*/
	protected CharsetEncoder(Charset cs,
                   float averageBytesPerChar,
                   float maxBytesPerChar,
                   byte[] replacement)
    {
        this.charset = cs;
        if (averageBytesPerChar <= 0.0f)
            throw new IllegalArgumentException("Non-positive "
                                               + "averageBytesPerChar");
        if (maxBytesPerChar <= 0.0f)
            throw new IllegalArgumentException("Non-positive "
                                               + "maxBytesPerChar");
        if (!Charset.atBugLevel("1.4")) {
            if (averageBytesPerChar > maxBytesPerChar)
                throw new IllegalArgumentException("averageBytesPerChar"
                                                   + " exceeds "
                                                   + "maxBytesPerChar");
        }
        this.replacement = replacement;
        this.averageBytesPerChar = averageBytesPerChar;
        this.maxBytesPerChar = maxBytesPerChar;
        replaceWith(replacement);
    }

##其他方法：
	
	/**
     * Returns the charset that created this encoder.  </p>
     *
     * @return  This encoder's charset
     */
    public final Charset charset() {
        return charset;
    }

	/**
     * Returns this encoder's replacement value. </p>
     *
     * @return  This encoder's current replacement,
     *          which is never <tt>null</tt> and is never empty
     */
    public final byte[] replacement() {
        return replacement;
    }
	