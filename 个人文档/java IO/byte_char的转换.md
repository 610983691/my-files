##转换

知道了byte用于InputStream/OutputStream,char用于Reader/Writer的读写。
那用byte读取到的内容如何展示？或者说byte写到文件就成了能看懂的文字呢？

首先参考链接：

[http://blog.csdn.net/yangfanend/article/details/6063911](http://blog.csdn.net/yangfanend/article/details/6063911)

###自己的笔记
对于一般的文件来说，文件的内容展示的不同（文本、图片）只是由于打开文件的程序对这个文件的解释不同造成的。
因此对一个文件的读写来说，只需要对字节进行读写就可以实现文件的复制等功能。
例子：

	public static void main(String[] s) throws Exception {
		File picture = new File("C:\\Users\\tongjie\\Desktop\\test\\test.jpg");
		byte[] bytebuffer = new byte[1024];//每次写1K
		FileInputStream fio = new FileInputStream(picture);
		File newFile = new File("copy.jpg");
		FileOutputStream outputStream = new FileOutputStream(newFile);

		while (fio.read(bytebuffer) != -1) {
			outputStream.write(bytebuffer);
		}
	}

	public static void main(String[] s) throws Exception {
		File picture = new File("C:\\Users\\tongjie\\Desktop\\test\\test.jpg");
		byte[] bytebuffer = new byte[1024];
		FileInputStream fio = new FileInputStream(picture);
		File newFile = new File("copy.jpg");
		FileOutputStream outputStream = new FileOutputStream(newFile);

		int fileSize = 0;
		int lengthOfThisTime;
		while ((lengthOfThisTime = fio.read(bytebuffer)) != -1) {
			fileSize++;
			outputStream.write(bytebuffer, 0, lengthOfThisTime);
		}
		System.out.println("一共是" + fileSize + "KB");
	}

> 上边的两个方法需要特别注意的是：while循环处不同的地方，一个是直接默认就写bytebuffer,一个是bytebuffer里边有多少就写多少字节。因此，通过这两个方式，最后copy出来的文件的大小是不一致的。使用第一个方法写的文件最后就是实际的1515*1024B，而使用第二个方式copy文件的大小就不一定是1024B*n的整数倍了。至于两个文件大小不一致，最后实际的文件显示的图片却一样这个就应该是图片处理文件的处理了，这里不做深究。

###使用字节流读取一个文本文件
	
	private static void testUserByteToReadChar() throws Exception {
		File txtFile = new File("C:\\Users\\tongjie\\Desktop\\test\\test.txt");
		FileInputStream fio = new FileInputStream(txtFile);
		byte[] byteBuffer = new byte[1024];
		while (fio.read(byteBuffer) != -1) {
			String s = new String(byteBuffer, StandardCharsets.UTF_8);
			System.out.println(s);
		}
	}
>需要注意的就是，文本文件的编码格式和这里指定的编码格式一致，不然就会产生乱码问题。
