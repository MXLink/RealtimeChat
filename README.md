[![RelatedCode](http://relatedcode.com/github/header.png)](http://relatedcode.com)

## OVERVIEW

RealtimeChat is a full native iPhone app to create realtime, text based chatrooms with Facebook/Twitter login.

![RealtimeChat](http://relatedcode.com/github/realtimechat11.png)
.
![RealtimeChat](http://relatedcode.com/github/realtimechat12.png)
.
![RealtimeChat](http://relatedcode.com/github/realtimechat13.png)

RealtimeChat is using Firebase as backend which is free for side projects or businesses that are just getting started. (Free plan: 5 GB Data Transfer, 50 Max Connections, 100 MB Data Storage).

Really easy to setup, just copy/paste the code and use your own chatrooms.

## FEATURES

- Realtime, live chat between multiple devices
- Facebook/Twitter login
- Mind-blowing fast chat actions
- No backend programming needed
- Automatic online/offline detection and handle
- Native and easy to customise user interface
- Arbitrary message sizes
- Automatic avatar images from Facebook/Twitter
- Smooth animations
- Handles multiple Twitter accounts on Login

## REQUIREMENTS

- Xcode 5
- iOS 7
- ARC

## INSTALLATION

**1.,** All RealtimeChat files located in *chat* directory. Vendor files located in *vendor* directory and external Frameworks in *framework* directory. Some resource files can be found in *resources* directory. Simply add *chat*, *resources*, *vendor* and *framework* directories to your project.

**2.,** You need the following iOS (built in) libraries: UIKit.framework, CoreGraphics.framework, Foundation.framework, SystemConfiguration.framework, Security.framework, CFNetwork.framework, Accounts.framework, Social.framework, libicucore.dylib, libc++.dylib.

To add libraries follow these steps: Click on the Targets → Your app name → and then the 'Build Phases' tab and then expand 'Link Binary With Libraries'. Click the plus button in the bottom left of the 'Link Binary With Libraries' section and choose library items from the list.

**3.,** You also need the latest Firebase.framework and FirebaseSimpleLogin.framework (already included). But if you need, you can download from here:

https://cdn.firebase.com/ObjC/Firebase.framework-LATEST.zip<br>
https://cdn.firebase.com/ios/FirebaseSimpleLogin.framework-LATEST.zip<br>

To add Firebase.framework and FirebaseSimpleLogin.framework, just unzip the above files and drag the .framework folders into your Xcode project under 'Frameworks'.

**4.,** Firebase makes use of Objective-C classes and categories, so you'll need to add '-ObjC' under 'Other Linker Flags' in 'Build Settings'. 

**5.,** Firebase currently does not support arm64. So you should choose 'Standard architectures (armv6, armv7s)' at 'Architectures' in 'Build Settings'.

**6.,** The *Prefix.pch* should contain:

```
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
```

**7.,** You also need three external libraries: AFNetworking, REComposeViewController and ProgressHUD (which are included). But if you need, you can download from here:

https://github.com/AFNetworking/AFNetworking<br>
https://github.com/romaonthego/REComposeViewController<br>
https://github.com/relatedcode/ProgressHUD<br>

To use this libraries, just add AFNetworking, REComposeViewController and ProgressHUD directories to your project.

**8.,** You need to use your own Firebase account. To get your Firebase account click here:

https://www.firebase.com/signup

**9.,** Replace existing Firebase account in *common.h*:

```
#define FIREBASE @"https://relatedchat.firebaseio.com"
```

**10.,** You need to register you app at Facebook and Twitter.

https://developers.facebook.com/apps<br>
https://dev.twitter.com/apps<br>

**11.,** At Facebook you need to enter your apps bundle identifier (Twitter does not require that).

![Facebook](http://relatedcode.com/codecanyon/facebook.png)

**12.,** You need to enter your Facebook App Id, Facebook App Secret and your Twitter Consumer Key, Twitter Consumer Secret at Firebase, Simple Login tab.

![Twitter](http://relatedcode.com/codecanyon/firebase_twitter.png)

**13.,** Replace your Facebook App Id and your Twitter Consumer Key in *common.h*

```
#define FACEBOOK_KEY @"1412541952322331"
#define TWITTER_KEY @"idEO49RKfbP7sjPmoSaZkg"
```

## CONTACT

Do you have any questions or idea? My email is: info@relatedcode.com or you can find some more info at [relatedcode.com](http://relatedcode.com)

## LICENSE

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
