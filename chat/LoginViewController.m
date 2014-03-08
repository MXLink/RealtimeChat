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

#import "LoginViewController.h"
#import "MenuViewController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface LoginViewController()
{
	NSArray *accounts;
	NSInteger selected;
}

@property (strong, nonatomic) IBOutlet UIButton *buttonFacebook;
@property (strong, nonatomic) IBOutlet UIButton *buttonTwitter;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation LoginViewController

@synthesize delegate;
@synthesize buttonFacebook;
@synthesize buttonTwitter;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Login";

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self
																			action:@selector(actionCancel)];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)showError:(id)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD showError:message Interacton:NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionFacebook:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:@"In progress..." Interacton:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	Firebase *ref = [[Firebase alloc] initWithUrl:FIREBASE];
	FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[authClient loginToFacebookAppWithId:FACEBOOK_KEY permissions:@[@"email"] audience:ACFacebookAudienceOnlyMe
					 withCompletionBlock:^(NSError *error, FAUser *user)
	{
		if (error == nil)
		{
			if (user != nil) [delegate didFinishLogin:ParseUserData(user.thirdPartyUserData)];
			[self dismissViewControllerAnimated:YES completion:^{ [ProgressHUD dismiss]; }];
		}
		else
		{
			NSString *message = [error.userInfo valueForKey:@"NSLocalizedDescription"];
			if (message == nil) message = @"Access to Facebook account was not granted";
			[self performSelectorOnMainThread:@selector(showError:) withObject:message waitUntilDone:NO];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionTwitter:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:@"In progress..." Interacton:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	selected = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ACAccountStore *account = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
	{
		if (granted)
		{
			accounts = [account accountsWithAccountType:accountType];
			//-------------------------------------------------------------------------------------------------------------------------------------
			if ([accounts count] == 0)
				[self performSelectorOnMainThread:@selector(showError:) withObject:@"No Twitter account was found" waitUntilDone:NO];
			//-------------------------------------------------------------------------------------------------------------------------------------
			if ([accounts count] == 1)	[self performSelectorOnMainThread:@selector(loginTwitter) withObject:nil waitUntilDone:NO];
			if ([accounts count] >= 2)	[self performSelectorOnMainThread:@selector(selectTwitter) withObject:nil waitUntilDone:NO];
		}
		else [self performSelectorOnMainThread:@selector(showError:) withObject:@"Access to Twitter account was not granted" waitUntilDone:NO];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)selectTwitter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter account" delegate:self cancelButtonTitle:nil
										  destructiveButtonTitle:nil otherButtonTitles:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSInteger i=0; i<[accounts count]; i++)
	{
		ACAccount *account = [accounts objectAtIndex:i];
		[action addButtonWithTitle:account.username];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[action addButtonWithTitle:@"Cancel"];
	action.cancelButtonIndex = accounts.count;
	[action showInView:self.view];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		selected = buttonIndex;
		[self loginTwitter];
	}
	else [ProgressHUD dismiss];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loginTwitter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *ref = [[Firebase alloc] initWithUrl:FIREBASE];
	FirebaseSimpleLogin *authClient = [[FirebaseSimpleLogin alloc] initWithRef:ref];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[authClient loginToTwitterAppWithId:TWITTER_KEY multipleAccountsHandler:^int(NSArray *usernames)
	{
		return selected;
	}
	withCompletionBlock:^(NSError *error, FAUser *user)
	{
		if (error == nil)
		{
			if (user != nil) [delegate didFinishLogin:ParseUserData(user.thirdPartyUserData)];
			[self dismissViewControllerAnimated:YES completion:^{ [ProgressHUD dismiss]; }];
		}
		else
		{
			NSString *message = [error.userInfo valueForKey:@"NSLocalizedDescription"];
			[self performSelectorOnMainThread:@selector(showError:) withObject:message waitUntilDone:NO];
		}
	}];
}

@end
