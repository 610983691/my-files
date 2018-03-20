##
参考网上的介绍，大致知道nio和io来说：
1.nio非阻塞的，传统的io来说是阻塞式的。
2.参考介绍
http://blog.csdn.net/it_man/article/details/38417761


##NIO--BUFFER
buffer read/write mode

flip()切换读/写模式

rewind() 把position置为0，limit值不变，因此可以实现数据重新读取。


