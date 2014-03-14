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
#import "UIImageView+AFNetworking.h"

#import "common.h"

#import "ChatViewController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatViewController()
{
	NSString *chatroom;
	NSDictionary *userinfo;
	
	BOOL initialized;
	FirebaseHandle handle;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatViewController

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)Chatroom Userinfo:(NSDictionary *)Userinfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	chatroom = [Chatroom copy];
	userinfo = [Userinfo copy];
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = chatroom;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered
																			 target:self action:@selector(actionPost:)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.separatorInset = UIEdgeInsetsZero;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[ProgressHUD show:@"Loading..." Interacton:NO];

	initialized = NO;
	self.messages = [[NSMutableArray alloc] init];
	self.firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE, chatroom]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
	{
		NSString *uid = [snapshot.value objectForKey:@"uid"];
		NSString *image = [snapshot.value objectForKey:@"image"];
		NSString *name = [snapshot.value objectForKey:@"name"];
		NSString *text = [snapshot.value objectForKey:@"text"];

		[self.messages addObject:@{@"uid":uid, @"image":image, @"name":name, @"text":text}];
		
		if (initialized) [self reloadTable];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	handle = [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		[self.firebase removeObserverWithHandle:handle];
		
		if (snapshot.value != [NSNull null])
		{
			[self reloadTable];
			[ProgressHUD dismiss];
		}
		else [ProgressHUD showError:@"No chat message." Interacton:NO];

		initialized	= YES;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPost:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
	composeViewController.hasAttachment = NO;
	composeViewController.delegate = self;
	composeViewController.text = @"";
	[composeViewController presentFromRootViewController];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)composeViewController:(REComposeViewController *)composeViewController didFinishWithResult:(REComposeResult)result
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[composeViewController dismissViewControllerAnimated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *text = composeViewController.text;
	if ((result == REComposeResultPosted) && ([text isEqualToString:@""] == NO))
	{
		if ([text length] > 140) text = [text substringToIndex:140];

		NSString *uid = [userinfo valueForKey:@"uid"];
		NSString *image = [userinfo valueForKey:@"image"];
		NSString *name = [userinfo valueForKey:@"name"];

		[[self.firebase childByAutoId] setValue:@{@"uid":uid, @"image":image, @"name":name, @"text":text}];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)reloadTable
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.tableView reloadData];
	
	NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
	[self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
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
	return self.messages.count;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGSize size = CGSizeMake(245, CGFLOAT_MAX);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *msg = [self.messages objectAtIndex:indexPath.row];
	NSString *text = [msg valueForKey:@"text"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect rect1 = [@"username" boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin
									 attributes:@{NSFontAttributeName:[UIFont fontWithName:FONT_BOLD size:12]} context:NULL];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGRect rect2 = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin
								   attributes:@{NSFontAttributeName:[UIFont fontWithName:FONT_NORMAL size:14]} context:NULL];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat height = rect1.size.height + rect2.size.height + 20;
	if (height < 44) height = 44;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return height;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *msg = [self.messages objectAtIndex:indexPath.row];

	NSString *uid1 = [msg valueForKey:@"uid"];
	NSString *name = [msg valueForKey:@"name"];
	NSString *text = [msg valueForKey:@"text"];
	
	NSString *uid2 = [userinfo valueForKey:@"uid"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[cell.imageView setImageWithURL:[NSURL URLWithString:[msg valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"avatar_blank"]];
	[cell.imageView.layer setCornerRadius:5.0];
	[cell.imageView.layer setMasksToBounds:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cell.textLabel.text = name;
	cell.textLabel.font = [UIFont fontWithName:FONT_BOLD size:12];
	cell.textLabel.textColor = [uid1 isEqualToString:uid2] ? [UIColor blueColor] : [UIColor lightGrayColor];
	cell.textLabel.numberOfLines = 1;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cell.detailTextLabel.text = text;
	cell.detailTextLabel.font = [UIFont fontWithName:FONT_NORMAL size:14];
	cell.detailTextLabel.textColor = [UIColor blackColor];
	cell.detailTextLabel.numberOfLines = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
