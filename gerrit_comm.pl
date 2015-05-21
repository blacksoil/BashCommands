#!/usr/bin/perl
use strict;
use Switch;
use Getopt::Long;
use Clipboard;
use XML::LibXML;

my $USERNAME = `whoami`;
chomp($USERNAME);

my $input_cherrypick = 0;
my $input_showpath = 0;
my $input_no_ChangeId = 0;
my $input_chid = 0;
my $input_url = 0;
my $input_sha1 = 0;
my $input_arg = 0;

my $gerrit_JSON;
my $gerrit_query;
my $subject;
my $project;
my $branch;
my $ref;
my $url;
my $author;
my $author_email;
my $committer;
my $committer_email;
my $status;
my $patchnum;

sub printUsage
{
	print "$0 [-cp] [-sha1|-url|-chid] arg\n";
	print "\t-url\t\tGerrit URL or just change number\n";
	print "\t-sha1\t\tAny git object: SHA1, HEAD, HEAD~2, tag, etc.\n";
	print "\t-chid\t\tGerrit Change-Id hash\n";
	print "\t-cp\t\tPrint just the cherry pick line for scripting purposes; also copy the cherry-pick line to clipboard\n";
	print "\t-path\t\tPrint the path of the project associated with the change\n";
}

sub processArgs
{
	if ($input_no_ChangeId && ($input_url || $input_chid)) { print "Warning: -nochid ony applies to -sha1 queries.\n"; }
	if ((!!$input_url + !!$input_chid + !!$input_sha1) > 1) { print "Error: -url, -chid, -sha1 are mutually exclusive.\n"; exit 1; }
	if ((!!$input_cherrypick + !!$input_showpath) > 1) { print "Error: -cp, -path are mutually exclusive.\n"; exit 1; }

	if ($input_chid) {
		$input_arg = $input_chid;
	}
	elsif ($input_url) {
		if ($input_url =~ m/[^0-9]*([0-9]+)$/) {
			$input_arg = $1;
		}
		else {
			print "Invalid url/change number.\n";
			exit 1;
		}
	}
	elsif ($input_sha1) {
		if ($input_no_ChangeId) {
			print "Not implemented yet, queried changes need to have a Change-Id line in their commit message.\n";
			exit 1;
			#$input_arg = $input_sha1;
		}
		else {
			my $temp = `git log -1 $input_sha1| grep Change-Id`;
			if (not $temp) {
				print "No Change-Id found in commit message for commit \"$input_sha1\".\n";
				exit 1;
			}
			if ($temp =~ m/Change-Id: ([0-9a-zA-Z]+)$/) {
				$input_arg = $1;
				#print "\"$input_arg\"";
			}
			else {
				print "No corresponding Change-Id found.\n";
				exit 1;
			}
		}
	}
	else {
		printUsage();
		exit 1;
	}
}

sub extractInfo
{
	my $info = shift;

	if ($info =~ m/"subject":"(.*?)",/) {
		$subject=$1;
	}

	if ($info =~ m/"project":"(.*?)"/) {
		$project=$1;
	}

	if ($info =~ m/"branch":"(.*?)"/) {
		$branch=$1;
	}

	if ($info =~ m/"ref":"(.*?)"/) {
		$ref=$1;
	}

	if ($info =~ m/"url":"(.*?)"/) {
		$url=$1;
	}

	if ($info =~ m/"owner":{"name":"(.*?)","email":"(.*?)"}/) {
		$author=$1;
		$author_email=$2;
	}

	if ($info =~ m/"uploader":{"name":"(.*?)","email":"(.*?)"}/) {
		$committer=$1;
		$committer_email=$2;
	}

	if ($info =~ m/"status":"(.*?)"/) {
		$status=$1;
	}

	if ($info =~ m/"currentPatchSet":{"number":"(.*?)"/) {
		$patchnum=$1;
	}
}

sub getPath
{
	my $parser = XML::LibXML->new();
	my $doc = $parser->parse_file($ENV{'TOP'} . '/.repo/manifest.xml');

	foreach my $p ($doc->findnodes('/manifest/project'))
	{
		if($project eq $p->findvalue('@name')) {
			return $ENV{'TOP'} . '/' . $p->findvalue('@path');
		}
	}

	return undef;
}

sub showInfo
{
	if ($input_cherrypick) {
		print "git fetch ssh://$USERNAME\@git-master:29418/$project $ref && git cherry-pick FETCH_HEAD -x\n";
		#Clipboard->copy("git fetch ssh://$USERNAME\@git-master:29418/$project $ref && git cherry-pick FETCH_HEAD");
	}
	elsif ($input_showpath) {
		print getPath() . "\n";
	}
	else {
		print "Subject\t\t$subject\n";
		print "Author\t\t$author ($author_email)\n";
		print "Committer\t$committer ($committer_email) patch #$patchnum\n";
		print "Project\t\t$project\n";
		print "Branch\t\t$branch\n";
		print "Status\t\t$status\n";
		print "Cherry-pick\tgit fetch ssh://$USERNAME\@git-master:29418/$project $ref && git cherry-pick FETCH_HEAD\n";
		print "URL\t\t$url\n";
		print "\n";
	}
}

sub splitInfo
{
	my $data = shift;
	my @instances;

	while ($data =~ m/{"project":"/) {
		$data =~ s/({"project":".*?)\n//;
		push(@instances, $1);
	}

	if (scalar(@instances) > 1 && $input_cherrypick) {
		print "More than one commit available for this change, please cherry-pick desired commit manually\n";
		exit 1;
	}

	if (scalar(@instances) == 0) {
		print "\nNo such change found.\n\n";
		exit 1;
	}

	foreach (@instances) {
		extractInfo($_);
		showInfo();
	}

}

#Argument Parsing
GetOptions(
'cp' => \$input_cherrypick,	 #Output only the cherry-pick command
'path' => \$input_showpath,	 #Output only the path for the project associated with the change
'sha1=s' => \$input_sha1,	 #Input a git object (HEAD, sha1, etc.)
'url=s' => \$input_url,		 #Input a url or change number
'chid=s' => \$input_chid,	 #Input a gerrit change ID
'nochid' => \$input_no_ChangeId, #Only used with sha1, if the sha1 commit is known not to have "Change-Id" in the commit message
);

processArgs();

# Construct gerrit query
$gerrit_query = "ssh git-master gerrit query";
unless ($input_no_ChangeId) {
	$gerrit_query = "$gerrit_query change:$input_arg";
}
else {
	$gerrit_query = "$gerrit_query commit:$input_arg";
}
$gerrit_query= "$gerrit_query --current-patch-set --format JSON";
#print "$gerrit_query\n";

# Execute gerrit query
$gerrit_JSON =`$gerrit_query`;
#print $gerrit_JSON."\n\n";

splitInfo($gerrit_JSON);

