//index.js
//获取应用实例
const app = getApp()

Page({
  data: {
    weatherDailyInfo:{},
    weatherNowInfo: {},
    cityInfo:"",
    suggestion:{},
    hasUserInfo: false,
    hasLocation: false,
  },
  onPullDownRefresh: function(){
    this.getWeather()
  },
  onReady:function(){
    setInterval(this.getWeather, 2*60*1000);
  },
  onLoad: function () {
    if (this.data.hasUserInfo && this.data.hasLocation) {
      //获取天气信息
      this.getDailyWeather()
      this.getNowWeather()
    } else{
      //获取位置信息
      wx.getLocation({
        success: res => {
          app.globalData.location = res
          this.setData({
            hasLocation:true
          })
          if (!this.data.hasUserInfo){
            wx.getUserInfo({
              success: res => {
                app.globalData.userInfo = res.userInfo
                this.setData({
                  userInfo: res.userInfo,
                  hasUserInfo: true
                })
                //这里请求一次api获取天气
                this.getDailyWeather()
                this.getNowWeather()
              }
            })
          }
        }
      })
    }
  },
  getDailyWeather: function() {
    //获取天气
    var self =this;
    wx.request({
      url: "https://bobbycat.club/api/weatherDaily/",
      data: app.globalData,
      method: "POST",
      success: function (res) {
        var weather = res.data.results[0];
        //这里不用this是因为，在自定义的函数里边调this是拿不到this的，，，，
        self.setData({
          weatherDailyInfo: weather.daily,
        })
      },
      fail: function (res) {
        console.log("额,请求失败了..")
      }
    })
  },
  getNowWeather:function(){
    //获取现在的天气
    var self = this;
    wx.request({
      url: "https://bobbycat.club/api/weathers/",
      data: app.globalData,
      method: "POST",
      success: function (res) {
        var weather = res.data.results[0];
        self.setData({
          weatherNowInfo: weather.now,
          cityInfo: weather.location.name
        })
      },
      fail: function (res) {
        console.log("额,请求失败了..")
      }
    })
  },
  getWeather: function () {
    //需要获取实时天气,位置信息是可变化的，需要最新的位置信息
    var self = this;
    wx.getLocation({
      success: res => {
        app.globalData.location = res
        wx.request({
          url: "https://bobbycat.club/api/weathers/",
          data: app.globalData,
          method: "POST",
          success: function (res) {
            var weather = res.data.results[0];
            self.setData({
              weatherNowInfo: weather.now,
              cityInfo: weather.location.name
            })
          },
          fail: function (res) {
            console.log("额,请求失败了..")
          }
        })
      }
    })
  }
})
