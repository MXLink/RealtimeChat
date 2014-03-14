//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProgressHUD.h"
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

#import "common.h"
#import "utilities.h"

#import "MenuViewController.h"
#import "LoginViewController.h"
#import "ChatViewController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MenuViewController()
{
	NSDictionary *userinfo;
	NSMutableArray *items;

	UIBarButtonItem *buttonLogin;
	UIBarButtonItem *buttonLogout;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MenuViewController

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Chat";

	userinfo = nil;

	items = [[NSMutableArray alloc] init];
	[items addObject:@"Awesome People"];
	[items addObject:@"Extreme Sports"];
	[items addObject:@"Gadget Nerds"];
	[items addObject:@"Celebrity Gossip"];

	buttonLogin = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(actionLogin)];
	buttonLogout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(actionLogout)];

	[self checkAuthStatus];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)showError:(id)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD showError:message Interacton:NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)checkAuthStatus
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:@"Please wait..." Interacton:NO];

	Firebase *ref = [[Firebase alloc] initWithUrl:FIREBASE];
	FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
	[authClient checkAuthStatusWithBlock:^(NSError *error, FAUser *user)
	{
		if (error == nil)
		{
			[ProgressHUD dismiss];

			if (user != nil)
			{
				userinfo = ParseUserData(user.thirdPartyUserData);
				self.navigationItem.rightBarButtonItem = buttonLogout;
			}
			else self.navigationItem.rightBarButtonItem = buttonLogin;
		}
		else
		{
			NSString *message = [error.userInfo valueForKey:@"NSLocalizedDescription"];
			[self performSelectorOnMainThread:@selector(showError:) withObject:message waitUntilDone:NO];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogin
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LoginViewController *loginViewController = [[LoginViewController alloc] init];
	loginViewController.delegate = self;

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
	navController.navigationBar.translucent = NO;
	navController.navigationBar.barTintColor = COLOR_TITLE;
	navController.navigationBar.tintColor = COLOR_TITLETEXT;
	navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:COLOR_TITLETEXT};
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didFinishLogin:(NSDictionary *)Userinfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	userinfo = [Userinfo copy];
	self.navigationItem.rightBarButtonItem = buttonLogout;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *ref = [[Firebase alloc] initWithUrl:FIREBASE];
	FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
	[authClient logout];

	userinfo = nil;
	self.navigationItem.rightBarButtonItem = buttonLogin;
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [items count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	cell.textLabel.text = [items objectAtIndex:indexPath.row];

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (userinfo != nil)
	{
		NSString *chatroom = [items objectAtIndex:indexPath.row];
		ChatViewController *chatViewController = [[ChatViewController alloc] initWith:chatroom Userinfo:userinfo];
		[self.navigationController pushViewController:chatViewController animated:YES];
	}
	else [self actionLogin];
}

@end
