#!/usr/bin/perl
#
# make a release candidate (moderately generic helper form making release tags)
# ./make-release.pl <release> <directory> "commit comment" --[new|release])
# e.g.
# ./make-release.pl 5.1.0 django_example_config "" --release
# ./make-release.pl 5.1.0 cspace_django_project "a few fixes and enhancements"
#
# will look in the existing release candidates (if any) for <release> and make the next one in the series
# e.g. if the current release candidate is 5.1.0-rc3, this script will make 5.1.0-rc4
#
# nb: if the release does not exist, you must specify either --release or --new.
#     e.g. 5.1.1 does not exist 5.1.1-rc1 is created.
#     to make the actual final release tag (e.g. 5.1.1) add --release
#     to make a new first release candidate (e.g. 5.1.2-rc1) add --new

use strict;

if (scalar @ARGV < 3)  {
  die "Need three (or four arguments): release directory \"comment (can be empty)\" [--new/release]\n";
}

my ($RELEASE, $DIRECTORY, $MSG, $NEW) = @ARGV;

chdir $DIRECTORY or die("could not change to $DIRECTORY directory");
    
my @tags = `git tag --list ${RELEASE}-*`;
if ($#tags < 0 && $NEW ne '--new' & $NEW ne '--release') {
   print "can't find any tags for ${RELEASE}-*\n";
   print "add --new if you want to make a new -rc1 for ${RELEASE}-*\n";
   print "add --release if you want to make a (release) tag for ${RELEASE}\n";
   exit(1);
}

my ($rc, $highest_rc, $release_to_check, $version_number);

foreach my $tag (sort (@tags)) {
    ($release_to_check, $rc) = $tag =~ /^(.*?)\-rc(\d+)/;
    #($release_to_check, $rc) = $tag =~ /^(.*?)\-(\d+)/;
    if ($release_to_check eq $RELEASE) {
        $version_number = $release_to_check;
        if (int($rc) > int($highest_rc)) {
            $highest_rc = $rc;
        }
    }
}

if ($version_number) {
    $highest_rc++;
    if ($NEW ne '') {
        print "version $version_number already exists and --new was specified\n";
        print "can't make a new version with this value.\n";
        print "specify a different version number or don't use --new to make a RC.\n";
        exit;
    }
    $version_number = "$version_number-rc$highest_rc";
}
else {
    if ($NEW eq '') {
        print "no release candidate found for $release_to_check and --new was not specified\n";
        print "if you want to make this the 1st release candidate for a new release, specify:\n";
        print "$0 $RELEASE $DIRECTORY \"$MSG\" --new\n";
        exit;
    }
    elsif ($NEW eq '--release') {
        print "making release tag for $RELEASE\n";
        $version_number = $RELEASE;
    }
    else {
        # they specified --new, so make a new rc1 for this new release
        print "making a new 1st release candidate for $RELEASE\n";
        $highest_rc = "1";
        $version_number = $RELEASE;
        $version_number = "$version_number-rc$highest_rc";
    }
}

my $tag_message = "Release tag $version_number.";
$tag_message .= ' ' . $MSG if $MSG;

print "verifying code is current and using master branch...\n";
system "git pull -v";
system "git checkout master";
print "updating CHANGELOG.txt...\n";
system "echo 'CHANGELOG for $DIRECTORY' > CHANGELOG.txt";
system "echo  >> CHANGELOG.txt";
system "echo 'OK, it is not a *real* change log, but a list of changes resulting from git log' >> CHANGELOG.txt";
system "echo 'with some human annotation after the fact.' >> CHANGELOG.txt";
system "echo  >> CHANGELOG.txt";
system "echo 'This is version $version_number' >> CHANGELOG.txt";
system "echo '$version_number' > VERSION";
system "date >> CHANGELOG.txt ; echo >> CHANGELOG.txt";
system "git log --oneline --decorate >> CHANGELOG.txt";
system "git commit -a -m 'revise change log and VERSION file for version $version_number'";
system "git push -v" ;
print  "git tag -a $version_number -m '$tag_message'\n";
system "git tag -a $version_number -m '$tag_message'";
system "git push --tags";

