WhoCall - 谁CALL我 ![](_images/AppIcon-60.png?raw=true)
=======

iOS来电信息语音提醒，无需越狱。（需要iOS 7.0及以上版本。)

骚扰电话预警、来电归属地提醒、联系人姓名播报，这些~~有中国特色~~人性化的电话功能，iOS上也应该有！

![](_images/screenshot-1.png?raw=true)

功能介绍
-------

那个陌生的来电号码是我的快递来了？是卖保险的？还是骗钱的电话？一听就知道！“谁CALL我”自动查询来电号码详细信息，在响铃的同时通过语音念给你听，让你接电话前心中有数。尤其适用于戴耳机的时候，不用掏出手机就能知道是谁打来电话。

超级简单易用，点两下开关即可完成设置。然后就可以把我忘掉，我会默默保护你。

* 骚扰电话预警 - 广告推销电话、诈骗电话、骚扰电话预警，还有部分快递号码、中介号码也会提醒。
* 来电归属地提醒 - 收录最新的全国手机号码归属地+各省市固话区号数据。
* 联系人姓名播报 - 如果是号码簿中的联系人来电，会在响铃的同时念出联系人姓名，防止漏接重要电话。

注：“骚扰电话预警”和“来电归属地”功能仅对中国大陆地区电话号码有效。


给开发者看的
-------

不要试图把这个App提交到App Store，我试过，不行，所以才干脆开源了。

此App使用了私有API获取来电号码，虽然API的调用经过伪装，能绕过自动检测，但是审核员会对此类App做特别关照，仍然有办法查出来调用的私有API。另外App常驻后台的做法也可能违反审核条例。

以下代码可能对你有用：

* `WCCallCenter` - 展示了如何用`dlsym`调用私有的C接口，并对函数名字符串做简单的加密，以绕过App提交过程中的自动检查。
* `WCLiarPhoneList` - 通过百度搜索电话号码，判断电话是否是骚扰电话，并提取出具体的类型（广告推销、诈骗……）。
* `WCPhoneLocator` - 电话号码归属地查询。


License
-------
You may use this project under the terms of the MIT License.


Acknowledgement
--------
* [FMDB](https://github.com/ccgus/fmdb)
* [UIKitCategoryAdditions](https://github.com/MugunthKumar/UIKitCategoryAdditions)
* [MMPDeepSleepPreventer](https://github.com/mruegenberg/MMPDeepSleepPreventer)
* [moquery](https://github.com/roymax/moquery)