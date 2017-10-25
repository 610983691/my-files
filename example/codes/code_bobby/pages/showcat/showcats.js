/*获取最热/最新的视频、图片动态 */


Page({
  data: {},
  onLoad:function(){
    this.setData({
      resultData: [{
        newsId: "1e23hd73",//该条动态的id
        newsPublishTime: "2017-10-10 13:33:33",//动态发布时间
        videoInfo: {
          videoTitlePageUrl: '',
          videoUrl: 'http://www.miaopai.com/show/ErWzjxwwdDH33-lLOf2zswMPez5E1G2uM-9SKg__.htm'
        },//视频相关信息（视频信息和图片信息互斥）
        pictureInfo: [],//图片信息
        textInfo: "这是loadmore一条动态",//该条动态的文本描述
        newsUserInfo: {
          userName: "nickName",//昵称
          avatarUrl: "http://www.sinaimg.cn/cj/yw/img/bg_compare.png",//头像
          appUserId: "2123dwe"//在app服务端存储的用户ID（唯一标识）
        }//动态所属的用户的用户信息
      }, {
        newsId: "1e23hd73",//该条动态的id
        newsPublishTime: "2017-10-10 13:33:33",//动态发布时间
        videoInfo: null,//视频相关信息（视频信息和图片信息互斥）
        pictureInfo: [{
          pictureTitlePageUrl: 'http://i1.sinaimg.cn/cj/basejs/loginLayer/login_back.png',
          pictureUrl: 'http://i1.sinaimg.cn/cj/basejs/loginLayer/login_back.png'
        }, {
          pictureTitlePageUrl: 'http://www.sinaimg.cn/cj/realstock/2012/images/back.8.png',
          pictureUrl: 'http://www.sinaimg.cn/cj/realstock/2012/images/back.8.png'
        }],//图片信息
        textInfo: "这是loadmore二条动态",//该条动态的文本描述
        newsUserInfo: {
          userName: "nickName2",//昵称
          avatarUrl: "http://www.sinaimg.cn/cj/yw/img/bg_compare.png",//头像
          appUserId: "2123dwe23"//在app服务端存储的用户ID（唯一标识）
        }//动态所属的用户的用户信息
      }]
    })
  },
  loadmoreBtn: function() {
    //正常情况这里应该是一个wx.request的ajax请求，去服务端获取新动态信息
    this.setData({
      resultData: [{
        newsId: "1e23hd73",//该条动态的id
        newsPublishTime: "2017-10-10 13:33:33",//动态发布时间
        videoInfo: {
          videoTitlePageUrl: '',
          videoUrl: 'http://www.miaopai.com/show/ErWzjxwwdDH33-lLOf2zswMPez5E1G2uM-9SKg__.htm'
        },//视频相关信息（视频信息和图片信息互斥）
        pictureInfo: [],//图片信息
        textInfo: "这是loadmore一条动态",//该条动态的文本描述
        newsUserInfo: {
          userName: "nickName",//昵称
          avatarUrl: "http://www.sinaimg.cn/cj/yw/img/bg_compare.png",//头像
          appUserId: "2123dwe"//在app服务端存储的用户ID（唯一标识）
        }//动态所属的用户的用户信息
      }, {
        newsId: "1e23hd73",//该条动态的id
        newsPublishTime: "2017-10-10 13:33:33",//动态发布时间
        videoInfo: null,//视频相关信息（视频信息和图片信息互斥）
        pictureInfo: [{
          pictureTitlePageUrl: 'http://i1.sinaimg.cn/cj/basejs/loginLayer/login_back.png',
          pictureUrl: 'http://i1.sinaimg.cn/cj/basejs/loginLayer/login_back.png'
        }, {
          pictureTitlePageUrl: 'http://www.sinaimg.cn/cj/realstock/2012/images/back.8.png',
          pictureUrl: 'http://www.sinaimg.cn/cj/realstock/2012/images/back.8.png'
        }],//图片信息
        textInfo: "这是loadmore二条动态",//该条动态的文本描述
        newsUserInfo: {
          userName: "nickName2",//昵称
          avatarUrl: "http://www.sinaimg.cn/cj/yw/img/bg_compare.png",//头像
          appUserId: "2123dwe23"//在app服务端存储的用户ID（唯一标识）
        }//动态所属的用户的用户信息
      }]
    })
  }
});

